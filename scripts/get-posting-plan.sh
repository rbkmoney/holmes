#!/bin/bash

set -o errexit
set -o pipefail
set -o errtrace

CWD="$(dirname $0)"
DAMSEL="${CWD}/../damsel"

USAGE=$(cat <<EOF
Usage: ${SCRIPTNAME} plan-id
  Shows a plan given a plan-id
  plan-id     Posting plan ID (string)

More information:
  [1]: https://github.com/rbkmoney/damsel
  [2]: https://github.com/rbkmoney/damsel/blob/b0806eb1/proto/accounter.thrift#L67
EOF
)

function usage {
    echo "${USAGE}"
    exit 127
}

[ -f woorlrc ] && source woorlrc

PLANID="${1}"
[ -z "${PLANID}" ] && usage

ACCOUNTER="http://${SHUMWAY:-shumway}:${SHUMWAY_PORT:-8022}/accounter"

"${WOORL[@]:-woorl}" -s "${DAMSEL}/proto/accounter.thrift" \
    "${ACCOUNTER}" Accounter GetPlan "\"${PLANID}\""