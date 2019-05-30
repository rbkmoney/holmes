#!/bin/bash
#
# This little guy repairs a failed invoice which have a payment capture
# erroneously marked as failed though it has succeeded on the other side.
#

set -e

CWD="$(dirname $0)"

INVOICE="${1}"

case ${INVOICE} in
  ""|"-h"|"--help" )
    echo -ne "Given ID of an invoice and a payment make it look like the payment capture succeeded and the "
    echo -ne "invoice has been paid. No transaction info is bound or rebound."
    echo
    echo
    echo -e "Usage: ${SCRIPTNAME} invoice_id"
    echo -e "  invoice_id      Invoice ID (string)."
    echo -e "  -h, --help      Show this help message."
    echo
    echo -e "More information:"
    echo -e "  https://github.com/rbkmoney/damsel/blob/master/proto/payment_processing.thrift"
    exit 0
    ;;
  * )
    ;;
esac

INVOICE_EVENTS=$(${CWD}/hellgate/get-invoice-events.sh ${INVOICE})
LAST_CHANGE=$(echo "${INVOICE_EVENTS}" | jq '.[-1].payload.invoice_changes[-1].invoice_payment_change')

PAYMENT=$(echo "${LAST_CHANGE}" | jq -r '.id')
SESSION=$(echo "${LAST_CHANGE}" | jq -r '.payload.invoice_payment_session_change')
TARGET=$(echo "${SESSION}" | jq -r '.target')

if [ \
  "${PAYMENT}" = "null" -o \
  "$(echo "${TARGET}" | jq -r '.captured')" = "null" -o \
  "$(echo "${SESSION}" | jq -r '.payload.session_started')" = "null" \
]; then
  err "Last seen change looks wrong for this repair scenario"
fi

# Essentially we have to simulate the failed session has been restarted and then
# finished successfully.
CHANGES=$(cat <<END
  [
    {
      "invoice_payment_change": {
        "id": "${PAYMENT}",
        "payload": {
          "invoice_payment_session_change": {
            "target": ${TARGET},
            "payload": {
              "session_finished": {
                "result": {
                  "succeeded": []
                }
              }
            }
          }
        }
      }
    }
  ]
END
)

# Then we should stuff it with previously reconstructed history
./repair-invoice.sh "${INVOICE}" "${CHANGES}"
