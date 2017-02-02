#!/bin/bash

SCRIPTNAME=$(basename $0)

get_state () {
    woorl $3 \
        -s damsel/proto/payment_processing.thrift \
        http://hellgate:8022/v1/processing/invoicing \
        Invoicing Get "$1" "$2"
}

case "$1" in
    ""|"-h"|"--help" )
        echo -e "Usage: ${SCRIPTNAME} invoice_id [woorl_opts]"
        echo -e "  invoice_id      invoice id (string)"
        echo -e "  -h, --help      help"
        echo -e "  more information: https://github.com/rbkmoney/damsel"
        exit 0
        ;;
    * )
        USERINFO="{\"id\":\"${SCRIPTNAME}\",\"type\":{\"service_user\":{}}}"
        INVOICE_ID="\"$1\""
        shift 1
        get_state "$USERINFO" "$INVOICE_ID" "$*"
        ;;
esac
