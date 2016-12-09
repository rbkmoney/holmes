#!/bin/bash

get_party () {
    woorl $3 \
        -s damsel/proto/payment_processing.thrift \
        http://hellgate:8022/v1/processing/partymgmt \
        PartyManagement Get "$1" "$2"
}

case "$1" in
    -h|--help )
        echo -e "Usage: get-party-state user_id party_id"
        echo -e "  user_id         user id"
        echo -e "  party_id        party id"
        echo -e "  -h, --help      help"
        exit 0
    * )
        USER="{\"id\":\"$1\"}"
        ID="\"$2\""
        shift 2
        get_events "$USER" "$ID" "$*"
esac
