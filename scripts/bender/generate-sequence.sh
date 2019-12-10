#!/bin/bash

set -o errexit
set -o pipefail

CWD="$(dirname $0)"
SCRIPTNAME=$(basename $0)
BENDER_PROTO="${CWD}/../../bender-proto"
MSGPACK_PROTO="${CWD}/../../msgpack-proto"

trap "rm -rf ${BENDER_PROTO}/proto/proto" EXIT

source "${CWD}/../lib/logging"

function usage {
  echo -e "Given external ID and sequence ID manually generate a new internal ID using Bender."
  echo
  echo -e "Usage: $(em ${SCRIPTNAME} external_id sequence_id [minimum])"
  echo -e "  $(em external_id)      External ID (string)"
  echo -e "  $(em sequence_id)      Sequence ID (string)"
  echo -e "  $(em minimum)          Minimum ID (number). The newly generated id would be equals to or bigger than the specified value."
  echo
  echo -e "More information:"
  echo -e "  https://github.com/rbkmoney/bender-proto/blob/master/proto/bender.thrift"
  exit $1
}

EXTERNAL_ID="${1}"
SEQUENCE_ID="${2}"
SEQUENCE_MINIMUM="${3:-0}"

case ${EXTERNAL_ID} in
  ""|"-h"|"--help" )
    usage 0
    ;;
  * )
    ;;
esac

[ -z "${SEQUENCE_ID}" -o -z "${SEQUENCE_MINIMUM}" ] && usage 127

GENERATION_SCHEMA="{\"sequence\":{\"sequence_id\":\"${SEQUENCE_ID}\", \"minimum\":${SEQUENCE_MINIMUM}}}"
CONTEXT="{\"nl\":{}}"

[ -f woorlrc ] && source woorlrc

mkdir ${BENDER_PROTO}/proto/proto
cp ${MSGPACK_PROTO}/proto/msgpack.thrift ${BENDER_PROTO}/proto/proto/msgpack.thrift

"${WOORL[@]:-woorl}" \
    -s "${BENDER_PROTO}/proto/bender.thrift" \
    "http://${BENDER:-bender}:8022/v1/bender" \
    Bender GenerateID "\"${EXTERNAL_ID}\"" "${GENERATION_SCHEMA}" "${CONTEXT}"
