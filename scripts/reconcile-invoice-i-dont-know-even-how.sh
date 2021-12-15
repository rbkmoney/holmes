#!/bin/bash

set -e

CWD="$(dirname $0)"
SCRIPTNAME="$(basename $0)"

source "${CWD}/lib/logging"

# Actual work is going here

INVOICE="${1}"
PAYMENT="${2}"

case ${INVOICE} in
  ""|"-h"|"--help" )
    echo -ne "Given ID of an invoice and a payment make it so that boss is angry no more. "
    echo
    echo
    echo -e "Usage: ${SCRIPTNAME} invoice_id payment_id"
    echo -e "  invoice_id      Invoice ID (string)."
    echo -e "  payment_id      Payment ID (string)."
    echo -e "  -h, --help      Show this help message."
    echo
    echo -e "More information:"
    echo -e "  https://github.com/rbkmoney/damsel/blob/master/proto/payment_processing.thrift"
    exit 0
    ;;
  * )
    ;;
esac

INVOICE_ST=$(${CWD}/hellgate/get-invoice-state.sh ${INVOICE})

if [ "$(echo "${INVOICE_ST}" | jq -r '.invoice.status.paid')" = "null" ]; then
  err "Invoice looks wrong for this repair scenario"
fi

PAYMENT_ST="$(echo "${INVOICE_ST}" | jq -r ".payments[] | .payment | select(.id == \"${PAYMENT}\")")"

if [ "$(echo "${PAYMENT_ST}" | jq -r '.status.captured')" = "null" ]; then
  err "Payment with id $(em "${PAYMENT}") looks wrong for this repair scenario"
fi

# Essentially we have to simulate the failed session has been restarted and then
# finished successfully.
CHANGES=$(cat <<END
  [
    {
      "invoice_payment_change": {
        "id": "${PAYMENT}",
        "payload": {
          "invoice_payment_status_changed": {
            "status": {
              "failed": {"failure": {
                "failure": {
                  "code": "authorization_failed",
                  "sub": {"code": "unknown"},
                  "reason": "Manually marked as failed at $(date) by @${USER}"
                }
              }}
            }
          }
        }
      }
    },
    {
      "invoice_status_changed": {
        "status": {
          "cancelled": {
            "details": "Manually marked as cancelled at $(date) by @${USER}"
          }
        }
      }
    }

  ]
END
)

PLANID="${INVOICE}.${PAYMENT}"
BATCH=$(${CWD}/get-posting-plan-batch.sh ${PLANID} 1)

# First we need to explicitly make invoice failed again. Amen.
${CWD}/fail-machine.sh "${INVOICE}"

# Then we should stuff it with previously reconstructed history
${CWD}/repair-invoice.sh --force --unset-timer "${INVOICE}" "${CHANGES}"

# And finally we should reconcile the state of accounts of participating parties.
${CWD}/submit-posting-plan.sh "${PLANID}-reverted" "$(${CWD}/revert-posting-batch.sh "${BATCH}")"
