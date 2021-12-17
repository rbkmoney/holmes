#!/bin/bash

set -e

CWD="$(dirname $0)"
SCRIPTNAME="$(basename $0)"

source "${CWD}/lib/logging"

INVOICE="${1}"
PAYMENT="${2}"
REFUND="${3}"

case ${INVOICE} in
  ""|"-h"|"--help" )
    echo -ne "Given ID of an invoice and a payment make it look like the payment capture succeeded and the "
    echo -ne "invoice has been paid. No transaction info is bound or rebound."
    echo
    echo
    echo -e "Usage: ${SCRIPTNAME} invoice_id payment_id refund_id"
    echo -e "  invoice_id      Invoice ID (string)."
    echo -e "  payment_id      Payment ID (string)."
    echo -e "  refund_id       Refund ID (string)."
    echo -e "  -h, --help      Show this help message."
    echo
    echo -e "More information:"
    echo -e "  https://github.com/rbkmoney/damsel/blob/master/proto/payment_processing.thrift"
    exit 0
    ;;
  * )
    ;;
esac

[ -z "${INVOICE}" ] && exit 127
[ -z "${PAYMENT}" ] && exit 127
[ -z "${REFUND}" ] && exit 127

STATUS=$(cat <<END
{
  "failed": {"failure": {
    "failure": {
      "code": "authorization_failed",
      "sub": {"code": "unknown"},
      "reason": "Manually marked as failed at $(date) by @${USER}"
    }
  }}
}
END
)

CHANGES=$(cat <<END
  [
    {
      "invoice_payment_change": {
        "id": "${PAYMENT}",
        "payload": {
          "invoice_payment_refund_change": {
            "id": "${REFUND}",
            "payload": {
              "invoice_payment_session_change": {
                "target": {
                  "refunded": []
                },
                "payload": {
                  "session_started": []
                }
              }
            }
          }
        }
      }
    },
    {
      "invoice_payment_change": {
        "id": "${PAYMENT}",
        "payload": {
          "invoice_payment_refund_change": {
            "id": "${REFUND}",
            "payload": {
              "invoice_payment_session_change": {
                "target": {
                  "refunded": []
                },
                "payload": {
                  "session_finished": {
                    "result": ${STATUS}
                  }
                }
              }
            }
          }
        }
      }
    },
    {
      "invoice_payment_change": {
        "id": "${PAYMENT}",
        "payload": {
          "invoice_payment_refund_change": {
            "id": "${REFUND}",
            "payload": {
              "invoice_payment_refund_status_changed": {
                "status": ${STATUS}
              }
            }
          }
        }
      }
    }
  ]
END
)

PLANID="${INVOICE}.${PAYMENT}.refund_session-${REFUND}"
BATCH=$(${CWD}/get-posting-plan-batch.sh ${PLANID} 1)

# First we need to explicitly make invoice failed again. Amen.
echo ${CWD}/fail-machine.sh "${INVOICE}"

# Then we should stuff it with previously reconstructed history
echo ${CWD}/repair-invoice.sh --force "${INVOICE}" "${CHANGES}"

# And finally we should reconcile the state of accounts of participating parties.
echo ${CWD}/submit-posting-plan.sh "${PLANID}-reverted" "$(${CWD}/revert-posting-batch.sh "${BATCH}")"
