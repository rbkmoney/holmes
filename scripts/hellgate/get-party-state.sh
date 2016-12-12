#!/bin/bash

get_party () {
    woorl $3 \
        -s damsel/proto/payment_processing.thrift \
        http://hellgate:8022/v1/processing/partymgmt \
        PartyManagement Get "$1" "$2"
}

case "$1" in
    -h|--help )
        NAME=`basename $0`
        echo -e "Usage: $NAME user_id party_id [woorl_opts]"
        echo -e "  user_id         user id (string)"
        echo -e "  party_id        party id (string)"
        echo -e "  -h, --help      help"
        echo -e "  more information: https://github.com/rbkmoney/damsel"
        exit 0
    * )
        USER="{\"id\":\"$1\"}"
        ID="\"$2\""
        shift 2
        get_events "$USER" "$ID" "$*"
esac
