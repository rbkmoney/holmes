#!/bin/bash

SCRIPTNAME=$(basename $0)

get_party () {
    woorl $3 \
        -s damsel/proto/payment_processing.thrift \
        http://hellgate:8022/v1/processing/partymgmt \
        PartyManagement Get "$1" "$2"
}

case "$1" in
    ""|"-h"|"--help" )
        echo -e "Usage: ${SCRIPTNAME} party_id [woorl_opts]"
        echo -e "  party_id        party id (string)"
        echo -e "  -h, --help      help"
        echo -e "  more information: https://github.com/rbkmoney/damsel"
        exit 0
        ;;
    * )
        USERINFO="{\"id\":\"${SCRIPTNAME}\",\"type\":{\"service_user\":{}}}"
        PARTY_ID="\"$1\""
        shift 1
        get_party "$USERINFO" "$PARTY_ID" "$*"
        ;;
esac
