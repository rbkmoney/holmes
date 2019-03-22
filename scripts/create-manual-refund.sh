#!/bin/bash

set -e

CWD="$(dirname $0)"
SCRIPTNAME="$(basename $0)"

source "${CWD}/lib/logging"

function usage {
  echo -e "Given ID of an invoice and a payment make payment refunded without actual refund proccess."
  echo
  echo -e "Usage: $(em ${SCRIPTNAME} invoice_id payment_id amount currency reason trx_id trx_timestamp)"
  echo -e "  $(em invoice_id)      Invoice ID (string)."
  echo -e "  $(em payment_id)      Payment ID (string), $(em 1) by default."
  echo -e "  $(em amount)          Amount (number)."
  echo -e "  $(em currency)        Currency code (string)."
  echo -e "  $(em reason)          Reason (string)."
  echo -e "  $(em trx_id)          Manual refund transaction ID (string)."
  echo -e "  $(em trx_timestamp)   Manual refund transaction timetamp (string)."
  echo
  echo -e "More information:"
  echo -e "  https://github.com/rbkmoney/damsel/blob/master/proto/payment_processing.thrift"
  exit 127
}

USERINFO=$(jq -nc "{id:\"${SCRIPTNAME}\", type:{service_user:{}}}")
INVOICE_ID="${1}"
PAYMENT_ID="${2}"
AMOUNT="${3}"
CURCODE="${4}"
REASON="${5}"
TRX_ID="${6}"
TRX_TIMESTAMP="${7}"

[ -z "${INVOICE_ID}" -o -z "${PAYMENT_ID}" -o -z "${AMOUNT}" -o -z "${CURCODE}" \
-o -z "${REASON}" -o -z "${TRX_ID}" -o -z "${TRX_TIMESTAMP}" ] && usage

PARAMS=$(jq -nc "{
    reason: \"${REASON}\",
    cash:{amount:${AMOUNT}, currency:{symbolic_code:\"${CURCODE}\"}},
    transaction_info: {
        id: \"${TRX_ID}\",
        timestamp: \"${TRX_TIMESTAMP}\",
        extra: {}
    }
}")

[ -f woorlrc ] && source woorlrc

${WOORL:-woorl} \
    -s damsel/proto/payment_processing.thrift \
    http://${HELLGATE:-hellgate}:8022/v1/processing/invoicing \
    Invoicing CreateManualRefund "${USERINFO}" "\"${INVOICE_ID}\"" "\"${PAYMENT_ID}\"" "${PARAMS}"

