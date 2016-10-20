#!/bin/sh

woorl $* \
    -s damsel/proto/cds.thrift \
    http://cds:8022/v1/keyring \
    Keyring Init 2 3
