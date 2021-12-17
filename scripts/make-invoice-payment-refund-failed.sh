#!/bin/bash
#
# This little guy repairs an invoice machine and makes a specific refund fail.
#

set -e

CWD="$(dirname $0)"

source "${CWD}/lib/logging"

function usage {
  echo -e "Given ID of an invoice and a payment make it look like the payment refunded has failed."
  echo
  echo -e "Usage: $(em ${SCRIPTNAME} invoice_id [payment_id] [refund_id])"
  echo -e "  $(em invoice_id)      Invoice ID (string)."
  echo -e "  $(em payment_id)      Payment ID (string), $(em 1) by default."
  echo -e "  $(em refund_id)       Refund ID (string), last one by default."
  echo
  echo -e "More information:"
  echo -e "  https://github.com/rbkmoney/damsel/blob/master/proto/payment_processing.thrift"
  exit 127
}

INVOICE="${1}"
PAYMENT="${2:-1}"
REFUND="${3}"

[ -z "${INVOICE}" -o -z "${PAYMENT}" ] && usage

STATE="$(${CWD}/hellgate/get-invoice-state.sh ${INVOICE})"

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
if [ "${REFUND_STATUS}" != "succeeded" ]; then
  err "Refund status ($(em ${REFUND_STATUS})) looks wrong for this repair scenario"
fi

CHANGES=$(cat <<END
  [
    {
      "invoice_payment_change": {
        "id": "${PAYMENT}",
        "payload": {
          "invoice_payment_refund_change": {
            "id": "${REFUND}",
            "payload": {
              "invoice_payment_refund_status_changed": {
                "status": {"failed": {"failure": {
                  "failure": {
                    "code": "authorization_failed",
                    "sub": {"code": "unknown"}
                  }
                }}}
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

${CWD}/fail-machine.sh "${INVOICE}"

${CWD}/repair-invoice.sh "${INVOICE}" "${CHANGES}"

${CWD}/submit-posting-plan.sh "${PLANID}-reverted" "$(${CWD}/revert-posting-batch.sh "${BATCH}")"
