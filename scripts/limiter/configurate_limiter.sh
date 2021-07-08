#!/bin/bash

set -o errexit
set -o pipefail

CWD="$(dirname $0)"
SCRIPTNAME=$(basename $0)
LIMITER_PROTO="${CWD}/../../limiter-proto"

trap "rm -rf ${LIMITER_PROTO}/proto/proto" EXIT

source "${CWD}/../lib/logging"

USAGE=$(cat <<EOF

  $(em Create configuration usage in limit counting.)
  Usage: ${SCRIPTNAME} [--set-body-currency CUR | --set-body-amount] --subtraction id started_at name description
    $(em id)                        Limit config ID (string)
    $(em started_at)                Timestamp (RFC3339 timestamp) Example: \"2021-07-06T01:02:03Z\"
    $(em name)                      Limit configuration name (string)
    $(em description)               Limit description (string)

    OPTIONAL:

    $(em --set-body-currency)       Set limit body type currency. Body type currency(ISO 4217)
    $(em --set-body-amount)         Set limit body type amount
    $(em --subtraction)             Limiter behaviour when process payment refund. After refund limit will decrease on refund amount.

  More information:
    https://github.com/rbkmoney/limiter-proto/blob/master/proto/configurator.thrift
EOF
)

function usage {
    echo -e "${USAGE}"
    exit 127
}

TEMP=$(getopt -o "" --longoptions help,set-body-currency:,set-body-amount,subtraction -n "${SCRIPTNAME}" -- "$@")
[ $? != 0 ] && usage

eval set -- "${TEMP}"

while true; do
  case "$1" in
    --help                    )  usage ;;
    --set-body-currency       )  BODY_TYPE=",\"body_type\":{\"cash\": {\"currency\": \"${2}\"}}" ; shift 2 ;;
    --set-body-amount         )  BODY_TYPE=",\"body_type\":{\"amount\": {}}"                     ; shift 1 ;;
    --subtraction             )  BEHAVIOUR=", \"op_behaviour\": {\"invoice_payment_refund\": {\"subtraction\": {}}}" ; shift 1 ;;
    --                        ) shift 1 ; break ;;
    *                         ) break ;;
  esac
done

ID="${1}"
STARTED_AT="${2}"
NAME="${3}"
DESCRIPTION="${4}"

[ -z "$ID" -o -z "$STARTED_AT" -o -z "$NAME" -o -z "$DESCRIPTION" ] && usage

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
