#!/bin/sh

woorl $* \
    -s damsel/proto/cds.thrift \
    http://${CDS}:${THRIFT_PORT}/v1/keyring \
    Keyring Init 2 3
