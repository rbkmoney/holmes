#!/bin/sh

if [ "$1" == "-h" ]; then
    echo -e "Usage: unlock-keyring [-h [help]] key"
    echo -e "  key    part of master key for keyring unlock"
    exit 0
fi

KEY="{\"content_type\":\"base64\",\"content\": \"$1\"}"

shift 1

woorl $* \
      -s damsel/proto/cds.thrift \
      http://cds:8022/v1/keyring \
      Keyring Unlock "${KEY}"