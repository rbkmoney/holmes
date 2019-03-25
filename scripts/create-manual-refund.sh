#!/bin/bash

set -e

CWD="$(dirname $0)"
SCRIPTNAME="$(basename $0)"

source "${CWD}/lib/logging"

function usage {
  echo -ne "Given ID of an invoice and a payment make payment refunded without actual refund proccess."
  echo -ne "You should bind transaction info by placing a file named "
  echo -ne "'trx.{invoice_id}.{payment_id}.json' under the feet."
  echo
  echo -e "Usage: $(em ${SCRIPTNAME} invoice_id payment_id amount currency reason)"
  echo -e "  $(em invoice_id)      Invoice ID (string)."
  echo -e "  $(em payment_id)      Payment ID (string), $(em 1) by default."
  echo -e "  $(em amount)          Amount (number)."
  echo -e "  $(em currency)        Currency code (string)."
  echo -e "  $(em reason)          Reason (string), $(em "Refunded manually") by default."
  echo
  echo -e "More information:"
  echo -e "  https://github.com/rbkmoney/damsel/blob/master/proto/payment_processing.thrift"
  exit 127
}

USERINFO=$(jq -nc "{id:\"${SCRIPTNAME}\", type:{service_user:{}}}")
INVOICE_ID="${1}"
PAYMENT_ID="${2:-1}"
AMOUNT="${3}"
CURCODE="${4}"
REASON="${5:-Refunded manually}"

[ -z "${INVOICE_ID}" -o -z "${PAYMENT_ID}" -o -z "${REASON}" ] && usage

TRXFILE="trx.${INVOICE_ID}.${PAYMENT_ID}.refund.json"

REASONINFO=$(jq -nc "{reason: \"${REASON}\"}")
PARAMS=${REASONINFO}

if [ ! -z "${AMOUNT}" ] && [ ! -z "${CURCODE}" ]; then
  CASHINFO=$(jq -nc "{cash: {amount:${AMOUNT}, currency:{symbolic_code:\"${CURCODE}\"}}}")
  PARAMS=$(echo ${PARAMS} ${CASHINFO} | jq -s add)
fi

if [ -f "${TRXFILE}" ]; then
  TRXINFO=$(jq -nc "{transaction_info: $(cat "${TRXFILE}")}")
  PARAMS=$(echo ${PARAMS} ${TRXINFO} | jq -s add)
fi

[ -f woorlrc ] && source woorlrc

${WOORL:-woorl} \
    -s damsel/proto/payment_processing.thrift \
    http://${HELLGATE:-hellgate}:8022/v1/processing/invoicing \
    Invoicing CreateManualRefund "${USERINFO}" "\"${INVOICE_ID}\"" "\"${PAYMENT_ID}\"" "${PARAMS}"

