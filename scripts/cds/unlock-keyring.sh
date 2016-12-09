#!/bin/bash

unlock_keyring () {
    KEY="{\"content_type\":\"base64\",\"content\":\"$1\"}"
    woorl $2 \
          -s damsel/proto/cds.thrift \
          http://172.17.0.30:8022/v1/keyring \
          Keyring Unlock "${KEY}"
}

case "$1" in
    -h|--help )
        echo -e "Usage: unlock-keyring key"
        echo -e "  key             part of master key for keyring unlock"
        echo -e "  -h, --help      help"
        exit 0
        ;;
    * )
        KEY="$1"
        shift 1
        unlock_keyring "$KEY" "$*"
esac
