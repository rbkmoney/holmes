#!/bin/bash

set -o errexit
set -o pipefail
set -o errtrace

CWD="$(dirname $0)"
DAMSEL="${CWD}/../damsel"

USAGE=$(cat <<EOF
Usage: ${SCRIPTNAME} plan-id batch-id
  Shows a plan batch given a plan-id and a batch-id.
  plan-id     Posting plan ID (string)
  batch-id    Posting batch ID (string)

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
BATCHID="${2}"
[ -z "${BATCHID}" ] && usage

ACCOUNTER="http://${SHUMWAY:-shumway}:${SHUMWAY_PORT:-8022}/accounter"

"${CWD}/get-posting-plan.sh" "${PLANID}" | \
      jq ".batch_list[] | select(.id == ${BATCHID})"
