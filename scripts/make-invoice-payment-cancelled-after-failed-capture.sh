#!/bin/bash
#
# This little guy repairs an invoice which have failed because of an unexpected
# error while trying to capture payment and we need to make it look like it was
# cancelled.
#

set -e

CWD="$(dirname $0)"

source "${CWD}/lib/logging"

# Actual work is going here

INVOICE="${1}"
REASON="${2:-Manually cancelled payment}"

case ${INVOICE} in
  ""|"-h"|"--help" )
    echo -ne "Given ID of an invoice make it look like last payment was cancelled after failed capture "
    echo -ne "attempt."
    echo
    echo
    echo -e "Usage: ${SCRIPTNAME} invoice_id [reason]"
    echo -e "  invoice_id      Invoice ID (string)."
    echo -e "  reason          Reason for manually reconstructed session failure (string)."
    echo -e "  -h, --help      Show this help message."
    echo
    echo -e "More information:"
    echo -e "  https://github.com/rbkmoney/damsel/blob/master/proto/payment_processing.thrift"
    exit 0
    ;;
  * )
    ;;
esac

INVOICE_EVENTS=$("${CWD}/hellgate/get-invoice-events.sh" "${INVOICE}")
LAST_CHANGE=$(echo "${INVOICE_EVENTS}" | jq '.[-1].payload.invoice_changes[-1].invoice_payment_change')

PAYMENT=$(echo "${LAST_CHANGE}" | jq -r '.id')
SESSION=$(echo "${LAST_CHANGE}" | jq -r '.payload.invoice_payment_session_change')
TARGET=$(echo "${SESSION}" | jq -r '.target')

if [ \
  "${PAYMENT}" = "null" -o \
  "$(echo "${TARGET}" | jq -r '.captured')" = "null" -o \
  "$(echo "${SESSION}" | jq -r '.payload.session_finished')" != "null" \
]; then
  err "Last seen change looks wrong for this repair scenario"
fi

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
                  "failed": {
                    "failure": {
                      "failure": {
                        "code": "authorization_failed",
                        "reason": "${REASON}"
                      }
                    }
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
          "invoice_payment_session_change": {
            "target": {
              "cancelled": []
            },
            "payload": {
              "session_started": []
            }
          }
        }
      }
    },
    {
      "invoice_payment_change": {
        "id": "${PAYMENT}",
        "payload": {
          "invoice_payment_session_change": {
            "target": {
              "cancelled": []
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
"${CWD}/repair-invoice.sh" "${INVOICE}" "${CHANGES}"
