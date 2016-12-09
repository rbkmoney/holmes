#!/bin/sh

if [ "$1" == "-h" ]; then
    echo -e "Usage: get-invoice-events [-h [help]] user_id invoice_id after limit"
    echo -e "  user_id         user id"
    echo -e "  invoice_id      invoice id"
    echo -e "  after           event id after which we want to get events"
    echo -e "  limit           limit of events"
    exit 0
fi

USER="{\"id\":\"$1\"}"
ID="\"$2\""
RANGE="{\"after\":$3,\"limit\":$4}"
shift 4

woorl $* \
    -s damsel/proto/payment_processing.thrift \
    http://hellgate:8022/v1/processing/invoicing \
    Invoicing GetEvents ${USER} ${ID} ${RANGE}
