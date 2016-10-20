#!/bin/sh

MACHINE_NS="\"${1}\""
MACHINE_ID="{\"id\":\"${2}\"}"
shift 2

woorl $* \
    -s damsel/proto/state_processing.thrift \
    http://machinegun:8022/v1/automaton \
    Automaton Repair ${MACHINE_NS} ${MACHINE_ID} \
        '{"content_type":"base64","content": "g2o="}'