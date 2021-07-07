#!/bin/bash

set -o errexit
set -o pipefail

CWD="$(dirname $0)"
SCRIPTNAME=$(basename $0)
LIMITER_PROTO="${CWD}/../../limiter-proto"

trap "rm -rf ${LIMITER_PROTO}/proto/proto" EXIT

source "${CWD}/../lib/logging"

USAGE=$(cat <<EOF

  Create configuration usage in limit counting.
  Usage: ${SCRIPTNAME}  [--set-body-currency CUR | --set-body-amount] --subtraction id started_at name description
    id                        Limit config ID (string)
    started_at                Timestamp (RFC3339 timestamp) Example: \"2021-07-06T01:02:03Z\"
    name                      Limit configuration name (string)
    description               Limit description (string)

    OPTIONAL:

    --set-body-currency       Set limit body type currency. Body type currency(ISO 4217)
    --set-body-amount         Set limit body type amount
    --subtraction             Limiter behaviour when process payment refund. After refund limit will decrease on refund amount.

  More information:
    https://github.com/rbkmoney/limiter-proto/blob/master/proto/configurator.thrift
EOF
)

function usage {
    echo "${USAGE}"
    exit 127
}

TEMP=$(getopt -o "" --long help,set-body-currency:,set-body-amount,subtraction -n "${SCRIPTNAME}" -- "$@")
[ $? != 0 ] && usage

eval set -- "${TEMP}"

while true; do
  case "$1" in
    --help                    )  usage ;;
    --set-body-currency       )  BODY_TYPE=",\"body_type\":{\"cash\": {\"currency\": \"${2}\"}}" ; shift 2 ;;
    --set-body-amount         )  BODY_TYPE=",\"body_type\":{\"amount\": {}}"                     ; shift 2 ;;
    --subtraction             )  BEHAVIOUR=", \"op_behaviour\": {\"invoice_payment_refund\": {\"subtraction\": {}}}" ; shift 1 ;;
    --                        ) shift 1 ; break ;;
    *                         ) break ;;
  esac
done

ID="${1}"
[ -z "${ID}" ] && usage
STARTED_AT="${2}"
[ -z "${STARTED_AT}" ] && usage
NAME="${3}"
[ -z "${NAME}" ] && usage
DESCRIPTION="${4}"
[ -z "${DESCRIPTION}" ] && usage


JSON=$(cat <<END
  {
    "id": "${ID}",
    "started_at": "${STARTED_AT}",
    "name": "${NAME}",
    "description": "${DESCRIPTION}"
    ${BODY_TYPE}
    ${BEHAVIOUR}
  }
END
)

[ -f woorlrc ] && source woorlrc

"${WOORL[@]:-woorl}" \
    -s "${LIMITER_PROTO}/proto/configurator.thrift" \
    "http://${LIMITER:-limiter}:8022/v1/configurator" \
    Configurator Create "${JSON}"