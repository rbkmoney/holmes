#!/bin/bash

get_state () {
    woorl $3 \
        -s damsel/proto/payment_processing.thrift \
        http://hellgate:8022/v1/processing/invoicing \
        Invoicing Get "$1" "$2"
}

case "$1" in
    -h|--help )
        echo -e "Usage: get-invoice-state user_id invoice_id"
        echo -e "  user_id         user id"
        echo -e "  invoice_id      invoice id"
        echo -e "  -h, --help      help"
        exit 0
    * )
        USER="{\"id\":\"$1\"}"
        ID="\"$2\""
        shift 2
        get_state "$USER" "$ID" "$*"
esac
