#!/bin/sh

CURRENCY=${1}
shift 1

[ -z "${CURRENCY}" ] && { echo "No currency code specified"; exit -1; }

woorl $* \
    -s damsel/proto/accounter.thrift \
    http://${SHUMWAY:-shumway}:8022/accounter \
    Accounter CreateAccount "{\"currency_sym_code\":\"${CURRENCY}\"}"
