#!/bin/bash

set -e

CWD="$(dirname $0)"
DAMSEL="${CWD}/../damsel"
SCRIPTNAME="$(basename $0)"

source "${CWD}/lib/logging"

function usage {
  echo -e "Given ID of an invoice and a payment start payment refund."
  echo
  echo -e "Usage: $(em ${SCRIPTNAME} invoice_id payment_id amount currency)"
  echo -e "  $(em invoice_id)      Invoice ID (string)."
  echo -e "  $(em payment_id)      Payment ID (string), $(em 1) by default."
  echo -e "  $(em amount)          Amount (number)."
  echo -e "  $(em currency)        Currency code (string)."
  echo
  echo -e "More information:"
  echo -e "  https://github.com/rbkmoney/damsel/blob/master/proto/payment_processing.thrift"
  exit 127
}

INVOICE="${1}"
PAYMENT="${2}"
AMOUNT="${3}"
CURCODE="${4}"

[ -z "${INVOICE}" -o -z "${PAYMENT}" -o -z "${AMOUNT}" -o -z "${CURCODE}" ] && usage

PARAMS=$(jq -nc "{cash:{amount:${AMOUNT}, currency:{symbolic_code:\"${CURCODE}\"}}}")
USERINFO=$(jq -nc "{id:\"${SCRIPTNAME}\", type:{service_user:{}}}")

[ -f woorlrc ] && source woorlrc

"${WOORL:-woorl}" \
    -s "${DAMSEL}/proto/payment_processing.thrift" \
    "http://${HELLGATE:-hellgate}:8022/v1/processing/invoicing" \
    Invoicing RefundPayment "${USERINFO}" "\"${INVOICE}\"" "\"${PAYMENT}\"" "${PARAMS}"
