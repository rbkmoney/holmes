#!/bin/bash

SCRIPTNAME=$(basename $0)

get_events () {
    woorl $4 \
        -s damsel/proto/payment_processing.thrift \
        http://hellgate:8022/v1/processing/invoicing \
        Invoicing GetEvents $1 $2 $3
}

case "$1" in
    ""|"-h"|"--help" )
        echo -e "Usage: ${SCRIPTNAME} invoice_id after limit [woorl_opts]"
        echo -e "  invoice_id      invoice id"
        echo -e "  after           event id after which we want to get events"
        echo -e "  limit           limit of events"
        echo -e "  -h, --help      help"
        echo -e "  more information: https://github.com/rbkmoney/damsel"
        exit 0
        ;;
    * )
        USERINFO="{\"id\":\"${SCRIPTNAME}\",\"type\":{\"service_user\":{}}}"
        INVOICE_ID="\"$1\""
        RANGE="{\"after\":$2,\"limit\":$3}"
        shift 3
        get_events "$USERINFO" "$INVOICE_ID" "$RANGE" "$*"
        ;;
esac
