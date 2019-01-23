#!/bin/bash

[ -f woorlrc ] && source woorlrc

SCRIPTNAME=$(basename $0)

get_party () {
    woorl $3 \
        -s damsel/proto/payment_processing.thrift \
        http://${HELLGATE}:${THRIFT_PORT}/v1/processing/partymgmt \
        PartyManagement Get "$1" "$2"
}

case "$1" in
    ""|"-h"|"--help" )
        echo -e "Fetch state of a party given its ID."
        echo
        echo -e "Usage: ${SCRIPTNAME} party_id [woorl_opts]"
        echo -e "  party_id        Party ID (string)."
        echo -e "  -h, --help      Show this help message."
        echo
        echo -e "More information:"
        echo -e "  https://github.com/rbkmoney/damsel/blob/a603319/proto/payment_processing.thrift"
        exit 0
        ;;
    * )
        USERINFO="{\"id\":\"${SCRIPTNAME}\",\"type\":{\"service_user\":{}}}"
        PARTY_ID="\"$1\""
        shift 1
        get_party "$USERINFO" "$PARTY_ID" "$*"
        ;;
esac
