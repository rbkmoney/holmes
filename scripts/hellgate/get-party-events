#!/bin/bash

get_events () {
    woorl $4 \
        -s damsel/proto/payment_processing.thrift \
        http://hellgate:8022/v1/processing/partymgmt \
        PartyManagement GetEvents "$1" "$2" "$3"
}

case "$1" in
    -h|--help )
        NAME=`basename $0`
        echo -e "Usage: $NAME user_id party_id after limit [woorl_opts]"
        echo -e "  user_id         user id (string)"
        echo -e "  party_id        party id (string)"
        echo -e "  after           event id after which we want to get events (integer)"
        echo -e "  limit           limit of events (integer)"
        echo -e "  -h, --help      help"
        echo -e "  more information: https://github.com/rbkmoney/damsel"
        exit 0
    * )
        USER="{\"id\":\"$1\"}"
        ID="\"$2\""
        RANGE="{\"after\":$3,\"limit\":$4}"
        shift 4
        get_events "$USER" "$ID" "$RANGE" "$*"
esac
