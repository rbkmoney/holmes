#!/bin/sh

USER=${1}
ID=${2}
shift 2

woorl $* \
    -s damsel/proto/payment_processing.thrift \
    http://hellgate:8022/v1/processing/invoicing \
    Invoicing Get "${USER}" "${ID}"
