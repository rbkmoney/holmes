#!/bin/bash

CWD="$(dirname $0)"
DAMSEL="${CWD}/../damsel"

USAGE=$(cat <<EOF
Usage: ${SCRIPTNAME} plan-id batch
  Prepares and commits a plan made up of the single posting batch provided by
  the user.
  plan-id     Posting plan ID (string)
  batch       Posting batch (json object, see [2])

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
BATCH="${2}"
[ -z "${BATCH}" ]  && usage

ACCOUNTER="http://${SHUMWAY:-shumway}:8022/accounter"

"${WOORL:-woorl}" -s "${DAMSEL}/proto/accounter.thrift" \
    "${ACCOUNTER}" Accounter Hold \
    "{\"id\": \"${PLANID}\", \"batch\": ${BATCH}}" && \
"${WOORL:-woorl}" -s "${DAMSEL}/proto/accounter.thrift" \
    "${ACCOUNTER}"  Accounter CommitPlan \
    "{\"id\": \"${PLANID}\", \"batch_list\": [${BATCH}]}"
