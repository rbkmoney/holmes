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

set -e -o pipefail

CWD="$(dirname $0)"

source "${CWD}/lib/logging"

# Actual work is going here

INVOICE="${1}"
PAYMENT="${2}"

function usage {
  echo -ne "Given ID of an invoice and a payment make it look like the payment processed successfully. "
  echo -ne "You can bind transaction info if you should, just place a file named "
  echo -ne "'trx.{invoice_id}.{payment_id}.json' under the feet."
  echo
  echo
  echo -e "Usage: ${SCRIPTNAME} invoice_id payment_id [--force]"
  echo -e "  invoice_id      Invoice ID (string)."
  echo -e "  payment_id      Payment ID (string)."
  echo -e "  --force         Force execution even when transaction info is missing."
  echo -e "  -h, --help      Show this help message."
  echo
  echo -e "More information:"
  echo -e "  https://github.com/rbkmoney/damsel/blob/master/proto/payment_processing.thrift"
  exit 127
}

[ -z "${INVOICE}" -o -z "${PAYMENT}" ] && usage

INVOICE_STATE=$(
  "${CWD}/hellgate/get-invoice-state.sh" "${INVOICE}"
)

PAYMENT_STATE=$(
  echo "${INVOICE_STATE}" | jq ".payments[].payment | select(.id == \"${PAYMENT}\")"
)

if [ \
  "${INVOICE_STATE}" = "" -o \
  "${PAYMENT_STATE}" = "" -o \
  "$(echo "${INVOICE_STATE}" | jq -r '.invoice.status | has("unpaid")')" != "true" -o \
  "$(echo "${PAYMENT_STATE}" | jq -r '.status | has("pending")')" != "true" \
]; then
  err "Invoice looks wrong for this repair scenario"
fi

LAST_CHANGE=$(
  "${CWD}/hellgate/get-invoice-events.sh" "${INVOICE}" |
    jq '.[-1].payload.invoice_changes[-1].invoice_payment_change'
)

SESSION=$(echo "${LAST_CHANGE}" | jq -r '.payload.invoice_payment_session_change')

if [ "${LAST_CHANGE}" = "null" ]; then
  err "Last seen change looks wrong for this repair scenario"
fi

LAST_PAYMENT="$(echo "${LAST_CHANGE}" | jq -r '.id')"
if [ "${LAST_PAYMENT}" != "${PAYMENT}" ]; then
  err "Last seen change related to another payment with id $(em "${LAST_PAYMENT}")"
fi

if [ "$(echo "${LAST_CHANGE}" | jq -r '.payload | has("invoice_payment_cash_flow_changed")')" == "true" ]; then

SESSION_CHANGE=$(cat <<END
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
END
)

else

  if [ $SESSION != "null" ] &&
     [ "$(echo "${SESSION}" | jq -r '.payload | has("session_finished")')" != "true" ]; then
    SESSION_CHANGE=""
  else
    err "Last seen change looks wrong for this repair scenario"
  fi
fi

TRXCHANGE=""
TRXFILE="trx.${INVOICE}.${PAYMENT}.json"

if [ -f "${TRXFILE}" ]; then

  TRXCHANGE=$(cat <<END
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
                "trx": $(cat "${TRXFILE}")
              }
            }
          }
        }
      }
    },
END
  )

else

  warn "No transaction info to bound, file $(em "${TRXFILE}") is missing"
  if [ "${3}" != "--force" ]; then
    err "Rerun with $(em --force) to proceed anyway"
  fi

fi

# Essentially we have to simulate the failed session has been restarted and then
# finished successfully.
CHANGES=$(cat <<END
  [
    ${SESSION_CHANGE}
    ${TRXCHANGE}
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
"${CWD}/repair-invoice.sh" "${INVOICE}" "${CHANGES}"
