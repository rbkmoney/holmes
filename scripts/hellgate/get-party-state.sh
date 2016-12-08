#!/bin/sh

USER="\"#{0}"\"
ID="\"#{1}"\"
shift 2

woorl $* \
    -s damsel/proto/payment_processing.thrift \
    http://hellgate:8022/v1/processing/partymgmt \
    PartyManagement Get ${USER} ${ID}
