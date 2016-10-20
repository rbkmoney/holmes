#!/bin/sh

set -e -o pipefail

PARTY_ID="'"${1}"'"
shift 1

SCHEMA="damsel/proto/payment_processing.thrift"
ENDPOINT="http://hellgate:8022/v1/processing/partymgmt"
WOORL="woorl $* -s ${SCHEMA} ${ENDPOINT} PartyManagement"
USERINFO="{\"id\":\"$0\"}"

CLAIM_ID="$(${WOORL} GetPendingClaim ${USERINFO} ${PARTY_ID} | jq .id)"
${WOORL} AcceptClaim ${USERINFO} ${PARTY_ID} ${CLAIM_ID}
