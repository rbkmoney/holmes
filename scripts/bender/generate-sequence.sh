#!/bin/bash

CWD="$(dirname $0)"
SCRIPTNAME=$(basename $0)
BENDER_PROTO="${CWD}/../../bender-proto"
MSGPACK_PROTO="${CWD}/../../msgpack-proto"

[ -f woorlrc ] && source woorlrc

EXTERNAL_ID="${1}"
SEQUENCE_ID="${2}"
SEQUENCE_MINIMUM="${3:-0}"

[ -z "${EXTERNAL_ID}" -o -z "${SEQUENCE_ID}" -o -z "${SEQUENCE_MINIMUM}" ] && exit 127


GENERATION_SCHEMA="{\"sequence\":{\"sequence_id\":\"${SEQUENCE_ID}\", \"minimum\":${SEQUENCE_MINIMUM}}}"
CONTEXT="{\"nl\":{}}"

mkdir ${BENDER_PROTO}/proto/proto
cp ${MSGPACK_PROTO}/proto/msgpack.thrift ${BENDER_PROTO}/proto/proto/msgpack.thrift

"${WOORL[@]:-woorl}" \
    -s "${BENDER_PROTO}/proto/bender.thrift" \
    "http://${BENDER:-bender}:8022/v1/bender" \
    Bender GenerateID "\"${EXTERNAL_ID}\"" "${GENERATION_SCHEMA}" "${CONTEXT}"

rm -rf ${BENDER_PROTO}/proto/proto
