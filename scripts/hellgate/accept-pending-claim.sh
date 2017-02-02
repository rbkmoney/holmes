#!/bin/bash

SCRIPTNAME=$(basename $0)

SCHEMA="damsel/proto/payment_processing.thrift"
ENDPOINT="http://hellgate:8022/v1/processing/partymgmt"

get_pending_claim() {
    CLAIM=$(woorl $3 -s "${SCHEMA}" "${ENDPOINT}" PartyManagement GetPendingClaim "$1" "$2")
    STATUS=$?
    [[ "$STATUS" != "0" ]] && exit $STATUS
    echo "$CLAIM" | jq .id
}

accept_claim() {
    woorl $4 -s "${SCHEMA}" "${ENDPOINT}" PartyManagement AcceptClaim "$1" "$2" "$3"
}

case "$1" in
    ""|"-h"|"--help" )
        echo -e "Given ID of a party accept its pending claim if there is one."
        echo
        echo -e "Usage: ${SCRIPTNAME} party_id [woorl_opts]"
        echo -e "  party_id        The ID of a party whose claim to accept"
        echo -e "  -h, --help      Help"
        echo
        echo -e "More information:"
        echo -e "  https://github.com/rbkmoney/damsel/blob/a603319/proto/payment_processing.thrift"
        exit 0
        ;;
    * )
        USERINFO="{\"id\":\"${SCRIPTNAME}\",\"type\":{\"service_user\":{}}}"
        PARTY_ID="\"${1}\""
        shift 1
        CLAIM_ID=$(get_pending_claim "$USERINFO" "$PARTY_ID" "$*")
        STATUS=$?
        [[ "$STATUS" != "0" ]] && exit $STATUS
        accept_claim "$USERINFO" "$PARTY_ID" "$CLAIM_ID" "$*"
        ;;
esac
