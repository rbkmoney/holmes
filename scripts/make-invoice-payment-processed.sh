#!/bin/bash
#
# This little guy repairs an invoice which have failed because of an unexpected
# error while trying to process payment though provider processed it successfully
# in the meantime.
#
# Attention! To attach some transaction info to the payment you must have a file
# name `trx.{invoice_id}.json' in the workdir which follows `domain.TransactionInfo'
# schema.
#

set -e

# Actual work is going here

INVOICE="${1}"
PAYMENT="${2:-1}"

case ${INVOICE} in
  ""|"-h"|"--help" )
    echo -ne "Given ID of an invoice and a payment make it look like the payment processed successfully. "
    echo -ne "You can bind transaction info if you should, just place a file named "
    echo -ne "'trx.{invoice_id}.{payment_id}.json' under the feet."
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

TRXCHANGE=

[ -f "trx.${INVOICE}.${PAYMENT}.json" ] && TRXCHANGE=$(cat <<END
    {
      "invoice_payment_change": {
        "id": "${PAYMENT}",
        "payload": {
          "invoice_payment_session_change": {
            "target": {
              "processed": []
            },
            "payload": {
              "session_transaction_bound": {
                "trx": $(cat "trx.${INVOICE}.${PAYMENT}.json")
              }
            }
          }
        }
      }
    }
END
)

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
              "processed": []
            },
            "payload": {
              "session_started": []
            }
          }
        }
      }
    },
    ${TRXCHANGE},
    {
      "invoice_payment_change": {
        "id": "${PAYMENT}",
        "payload": {
          "invoice_payment_session_change": {
            "target": {
              "processed": []
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
