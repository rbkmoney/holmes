#!/bin/bash

USAGE=$(cat <<EOF
Usage: ${SCRIPTNAME} invoice-id invoice-changes
  Repairs an invoice and stuffs it with the user-provided list of invoice
  changes.
  invoice-id           Invoice ID (string)
  invoice-changes      Invoice changes (json array)

More information:
  https://github.com/rbkmoney/damsel
EOF
)

function usage {
    echo "${USAGE}"
    exit 127
}

[ -f woorlrc ] && source woorlrc

INVOICE="${1}"
[ -z "${INVOICE}" ] && usage
INVOICE_CHANGES="${2}"
[ -z "${INVOICE_CHANGES}" ] && usage

USERINFO='{"id":"woorl","type":{"service_user":{}}}'

${WOORL:-woorl} \
    -s damsel/proto/payment_processing.thrift \
    "http://${HELLGATE:-hellgate}:8022/v1/processing/invoicing" \
    Invoicing Repair "${USERINFO}" "\"${INVOICE}\"" "${INVOICE_CHANGES}" "{}"
