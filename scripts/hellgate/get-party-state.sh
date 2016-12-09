#!/bin/sh

if [ "$1" == "-h" ]; then
    echo -e "Usage: get-party-state [-h [help]] user_id party_id"
    echo -e "  user_id       user id"
    echo -e "  party_id      party id"
    exit 0
fi

USER="{\"id\":\"$1\"}"
ID="\"$2\""
shift 2

woorl $* \
    -s damsel/proto/payment_processing.thrift \
    http://hellgate:8022/v1/processing/partymgmt \
    PartyManagement Get "${USER}" "${ID}"
