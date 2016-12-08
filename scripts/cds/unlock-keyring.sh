#!/bin/sh

KEY="\"#{0}\""
shift 1

woorl $* \
    -s damsel/proto/cds.thrift \
    http://cds:8022/v1/keyring \
    Keyring Unlock ${KEY}
