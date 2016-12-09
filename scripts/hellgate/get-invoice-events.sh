#!/bin/bash

get_events () {
    woorl $4 \
        -s damsel/proto/payment_processing.thrift \
        http://hellgate:8022/v1/processing/invoicing \
        Invoicing GetEvents $1 $2 $3
}

case "$1" in
    -h|--help )
        echo -e "Usage: get-invoice-events user_id invoice_id after limit"
        echo -e "  user_id         user id"
        echo -e "  invoice_id      invoice id"
        echo -e "  after           event id after which we want to get events"
        echo -e "  limit           limit of events"
        echo -e "  -h, --help      help"
        exit 0
    * )
        USER="{\"id\":\"$1\"}"
        ID="\"$2\""
        RANGE="{\"after\":$3,\"limit\":$4}"
        shift 4
        get_events "$USER" "$ID" "$RANGE" "$*"
esac
