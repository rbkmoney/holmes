#!/bin/bash
#
# This little guy repairs a failed invoice which have a payment capture
# erroneously marked as failed though it has succeeded on the other side.
#

set -e

INVOICE="${1}"
PAYMENT="${2:-1}"

case ${INVOICE} in
  ""|"-h"|"--help" )
    echo -ne "Given ID of an invoice and a payment make it look like the payment capture succeeded and the "
    echo -ne "invoice has been paid. No transaction info is bound or rebound."
    echo
    echo
    echo -e "Usage: ${SCRIPTNAME} invoice_id [payment_id]"
    echo -e "  invoice_id      Invoice ID (string)."
    echo -e "  payment_id      Payment ID (string), by default = '1'."
    echo -e "  -h, --help      Show this help message."
    echo
    echo -e "More information:"
    echo -e "  https://github.com/rbkmoney/damsel/blob/master/proto/payment_processing.thrift"
    exit 0
    ;;
  * )
    ;;
esac

# Essentially we have to simulate the failed session has been restarted and then
# finished successfully.
CHANGES=$(cat <<END
  [
    {
      "invoice_payment_change": {
        "id": "${PAYMENT}",
        "payload": {
          "invoice_payment_session_change": {
            "target": {
              "captured": []
            },
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
