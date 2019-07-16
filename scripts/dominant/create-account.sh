#!/bin/sh

CWD="$(dirname $0)"
DAMSEL="${CWD}/../../damsel"

CURRENCY=${1}
shift 1

[ -z "${CURRENCY}" ] && { echo "No currency code specified"; exit -1; }

"${WOORL[@]:-woorl}" $* \
    -s "${DAMSEL}/proto/accounter.thrift" \
    "http://${SHUMWAY:-shumway}:8022/accounter" \
    Accounter CreateAccount "{\"currency_sym_code\":\"${CURRENCY}\"}"
