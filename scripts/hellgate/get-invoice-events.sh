#!/bin/sh                                                                                                                                                                                                   

USER=${1}
ID=${2}
RANGE=${3}
shift 3

woorl $* \
    -s damsel/proto/payment_processing.thrift \
    http://hellgate:8022/v1/processing/invoicing \
    Invoicing GetEvents "${USER}" "${ID}" "${RANGE}"
