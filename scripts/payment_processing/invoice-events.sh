#!/bin/sh

USER="\"#{0}"\"
ID="\"#{1}"\"
RANGE="\"#{2}"\"
shift 3

woorl $* \
    -s damsel/proto/payment_processing.thrift \
    http://hellgate:8022/v1/processing/invoicing \
    Invoicing GetEvents ${USER} ${ID} ${RANGE}
