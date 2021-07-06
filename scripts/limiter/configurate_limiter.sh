#!/bin/bash

set -o errexit
set -o pipefail

CWD="$(dirname $0)"
SCRIPTNAME=$(basename $0)
LIMITER_PROTO="${CWD}/../../limiter-proto"

trap "rm -rf ${LIMITER_PROTO}/proto/proto" EXIT

source "${CWD}/../lib/logging"

function usage {
  echo -e "Create configuration usage in limit counting."
  echo
  echo -e "Usage: $(em ${SCRIPTNAME} id started_at name description --set-body BODY --set-behaviour BEHAVIOUR)"
  echo -e "  $(em id)              Limit config ID (string)"
  echo -e "  $(em started_at)      Timestamp (RFC3339 timestamp) Example: \"2021-07-06T01:02:03Z\""
  echo -e "  $(em name)            Limit configuration name.(string)"
  echo -e "  $(em description)     Limit description (string)"
  echo -e "  OPTIONAL: "
  echo -e "  $(em --set-body)      Set limit body type amount or currency. BODY:"
  echo -e "     $(em -amount)         Body type amount"
  echo -e "     $(em -currency)       Body type currency(ISO 4217)"
  echo -e "  $(em --set-behaviour) Limiter behaviour when process payment refund. BEHAVIOUR:"
  echo -e "     $(em -subtraction)"
  echo -e "     $(em -addition)"

  echo
  echo -e "More information:"
  echo -e "  https://github.com/rbkmoney/limiter-proto/blob/master/proto/configurator.thrift"
  exit 127
}

ID="${1}"
STARTED_AT="${2}"
NAME="${3}"
DESCRIPTION="${4}"
BODY_TYPE=""
BEHAVIOUR=""

behaviour () {
    case $1 in
      -subtraction ) OP="{\"subtraction\": {}}" ;;
      -addition    ) OP="{\"addition\": {}}"    ;;
      *            ) usage                      ;;
    esac

    BEHAVIOUR=", \"op_behaviour\": {\"invoice_payment_refund\": ${OP}}"
}

if [ "${5}" = '--set-body' ]; then
  case "$6" in
    -amount   ) BODY_TYPE=",\"body_type\":{\"amount\": {}}" ;;
    -currency ) BODY_TYPE=",\"body_type\":{\"cash\": {\"currency\": \"${7}\"}}" ;;
    *         ) usage ;;
  esac

  if [ "${6}" = "-amount" ] && [ "$7" = '--set-behaviour' ]; then
    behaviour "${8}"
  fi
  if [ "${6}" = "-currency" ] && [ "$8" = '--set-behaviour' ]; then
    behaviour "${9}"
  fi
fi

if [ "${5}" = '--set-behaviour' ]; then
  behaviour "${6}"
fi


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
