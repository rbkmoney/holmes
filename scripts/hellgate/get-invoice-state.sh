#!/bin/bash

CWD="$(dirname $0)"
DAMSEL="${CWD}/../../damsel"

[ -f woorlrc ] && source woorlrc

SCRIPTNAME=$(basename $0)

get_state () {
    ${WOORL:-woorl} \
        -s "${DAMSEL}/proto/payment_processing.thrift" \
        "http://${HELLGATE:-hellgate}:8022/v1/processing/invoicing" \
        Invoicing Get "$1" "$2"
}

case "$1" in
    ""|"-h"|"--help" )
        echo -e "Fetch state of an invoice given its ID."
        echo
        echo -e "Usage: ${SCRIPTNAME} invoice_id [woorl_opts]"
        echo -e "  invoice_id      Invoice ID (string)."
        echo -e "  -h, --help      Show this help message."
        echo
        echo -e "More information:"
        echo -e "  https://github.com/rbkmoney/damsel/blob/a603319/proto/payment_processing.thrift"
        exit 0
        ;;
    * )
        USERINFO="{\"id\":\"${SCRIPTNAME}\",\"type\":{\"service_user\":{}}}"
        INVOICE_ID="\"$1\""
        shift 1
        get_state "$USERINFO" "$INVOICE_ID"
        ;;
esac
