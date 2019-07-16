#!/bin/bash

CWD="$(dirname $0)"
DAMSEL="${CWD}/../../damsel"

[ -f woorlrc ] && source woorlrc

SCRIPTNAME=$(basename $0)

get_events () {
    ${WOORL:-woorl} $4 \
        -s "${DAMSEL}/proto/payment_processing.thrift" \
        "http://${HELLGATE:-hellgate}:8022/v1/processing/partymgmt" \
        PartyManagement GetEvents "$1" "$2" "$3"
}

case "$1" in
    ""|"-h"|"--help" )
        echo -e "Given ID of a party fetch a number of events emitted by this party."
        echo
        echo -e "Usage: ${SCRIPTNAME} party_id limit [after] [woorl_opts]"
        echo -e "  party_id        Party ID (string)."
        echo -e "  limit           Limit of number of events to fetch."
        echo -e "  after           Event ID after which we want to fetch events." \
                                  "Leave it out to fetch events from the very start."
        echo -e "  -h, --help      help"
        echo
        echo -e "More information:"
        echo -e "  https://github.com/rbkmoney/damsel/blob/a603319/proto/payment_processing.thrift"
        exit 0
        ;;
    * )
        USERINFO="{\"id\":\"${SCRIPTNAME}\",\"type\":{\"service_user\":{}}}"
        PARTY_ID="\"$1\""
        shift 1
        LIMIT="$1"
        shift 1
        if [ -n "$1" ]; then
            RANGE="{\"after\":$1,\"limit\":${LIMIT}}"
            shift 1
        else
            RANGE="{\"limit\":${LIMIT}}"
        fi
        get_events "$USERINFO" "$PARTY_ID" "$RANGE" "$*"
        ;;
esac
