#!/bin/bash
#
# This little guy repairs an invoice machine and makes a specific refund succeed,
# in spite of the fact that provider no longer service refunds.
#

set -e

CWD="$(dirname $0)"

source "${CWD}/lib/logging"

function usage {
  echo -e "Given ID of an invoice and a payment make it look like the payment was refunded successfully."
  echo
  echo -e "Usage: $(em ${SCRIPTNAME} invoice_id [payment_id] [refund_id])"
  echo -e "  $(em invoice_id)      Invoice ID (string)."
  echo -e "  $(em payment_id)      Payment ID (string), $(em 1) by default."
  echo -e "  $(em refund_id)       Refund ID (string), last one by default."
  # echo -e "  $(em amount)          Amount (number)."
  # echo -e "  $(em currency)        Currency code (string)."
  echo
  echo -e "More information:"
  echo -e "  https://github.com/rbkmoney/damsel/blob/master/proto/payment_processing.thrift"
  exit 127
}

INVOICE="${1}"
PAYMENT="${2:-1}"
REFUND="${3}"
# AMOUNT="${3}"
# CURCODE="${4}"

[ -z "${INVOICE}" -o -z "${PAYMENT}" ] && usage

# CASH=$(cat <<END
# {"amount":${AMOUNT},"currency":{"symbolic_code":"${CURCODE}"}}
# END
# )

STATE=$("${CWD}/hellgate/get-invoice-state.sh" "${INVOICE}")

info "Going on with payment $(em ${PAYMENT}) ..."

PAYMENT_STATE=$(echo "${STATE}" | jq ".payments[] | select(.payment.id == \"${PAYMENT}\")")
if [ "${PAYMENT_STATE}" = "" ]; then
  err "No such payment"
fi

PAYMENT_STATUS=$(echo "${PAYMENT_STATE}" | jq -r ".payment.status | keys[0]")
if [ "${PAYMENT_STATUS}" != "captured" ]; then
  err "Payment status ($(em ${PAYMENT_STATUS})) looks wrong for this repair scenario"
fi

REFUND_STATE=$(echo "${PAYMENT_STATE}" | jq ".refunds[${REFUND:--1}]")
if [ "${REFUND_STATE}" = "null" ]; then
  err "No refunds found"
fi

REFUND=$(echo "${REFUND_STATE}" | jq -r ".id")
info "Going on with refund $(em ${REFUND}) ..."

REFUND_STATUS=$(echo "${REFUND_STATE}" | jq -r ".status | keys[0]")
if [ "${REFUND_STATUS}" != "pending" ]; then
  err "Refund status ($(em ${REFUND_STATUS})) looks wrong for this repair scenario"
fi

# REFUND_FAILURE_REASON=$(echo "${REFUND_STATE}" | jq -r '.status.failed.failure.failure.reason')
# if (echo "${REFUND_FAILURE_REASON}" | grep -v "Invalid terminal identifier"); then
#   err "Refund failure reason ($(em "${REFUND_FAILURE_REASON}")) looks wrong for this repair scenario"
# fi

# REFUND_BODY="$(echo "${REFUND_STATE}" | jq -c '.cash')"
# if [ "${REFUND_BODY}" != "${CASH}" ]; then
#   err "Refund body ($(em "${REFUND_BODY}")) does not match"
# fi

# REFUND_NEXT=$((${REFUND} + 1))

# REFUND_CREATED=$(
#   ${CWD}/hellgate/get-invoice-events.sh ${INVOICE} | \
#     jq "[ " \
#       ".[] | .payload.invoice_changes | " \
#       ".[] | select(.invoice_payment_change.id == \"${PAYMENT}\") | " \
#       "select(.invoice_payment_change.payload.invoice_payment_refund_change.id == \"${REFUND}\") |" \
#       " ][0]" | \
#     jq "setpath([\"invoice_payment_change\",\"payload\",\"invoice_payment_refund_change\",\"id\"]; \"${REFUND_NEXT}\")" | \
#     jq "setpath([\"invoice_payment_change\",\"payload\",\"invoice_payment_refund_change\",\"payload\",\"invoice_payment_refund_created\",\"refund\",\"id\"]; \"${REFUND_NEXT}\")"
# )

    # ${REFUND_CREATED},
    # {
    #   "invoice_payment_change": {
    #     "id": "${PAYMENT}",
    #     "payload": {
    #       "invoice_payment_refund_change": {
    #         "id": "${REFUND}",
    #         "payload": {
    #           "invoice_payment_session_change": {
    #             "target": {"refunded": []},
    #             "payload": {"session_started": []}
    #           }
    #         }
    #       }
    #     }
    #   }
    # },

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
                "target": {"refunded": []},
                "payload": {
                  "session_finished": {
                    "result": {"succeeded": []}
                  }
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
