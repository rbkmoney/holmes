#!/bin/bash

set -o errexit
set -o pipefail

CWD="$(dirname $0)"
SCRIPTNAME=$(basename $0)
LIMITER_PROTO="${CWD}/../../limiter-proto"

trap "rm -rf ${LIMITER_PROTO}/proto/proto" EXIT

source "${CWD}/../lib/logging"

USAGE=$(cat <<EOF

  $(em Get limit configuration by id.)
  Usage: ${SCRIPTNAME} id
    $(em id)  Limit config ID (string)

  More information:
    https://github.com/rbkmoney/limiter-proto/blob/master/proto/configurator.thrift
EOF
)

function usage {
    echo -e "$USAGE"
    exit 127
}

ID="$1"

[ -z "$ID" ] && usage

[ -f woorlrc ] && source woorlrc

"${WOORL[@]:-woorl}" \
    -s "${LIMITER_PROTO}/proto/configurator.thrift" \
    "http://${LIMITER:-limiter}:8022/v1/configurator" \
    Configurator Get "\"$ID\""


