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
        NAME=`basename $0`
        echo -e "Usage: $NAME key [woorl_opts]"
        echo -e "  key             part of master key for keyring unlock (string)"
        echo -e "  -h, --help      help"
        echo -e "  more information: https://github.com/rbkmoney/damsel"
        exit 0
        ;;
    * )
        KEY="$1"
        shift 1
        unlock_keyring "$KEY" "$*"
esac
