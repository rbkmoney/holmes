#!/bin/sh

CWD="$(dirname $0)"
MGPROTO="${CWD}/../../mgproto"

[ -f woorlrc ] && source woorlrc

MACHINE_NS="\"${1}\""
MACHINE_ID="{\"id\":\"${2}\"}"
shift 2

"${WOORL[@]:-woorl}" $* \
    -s "${MGPROTO}/proto/state_processing.thrift" \
    "http://${MACHINEGUN:-machinegun}:8022/v1/automaton" \
    Automaton Repair "${MACHINE_NS}" "${MACHINE_ID}" \
        '{"content_type":"base64","content": "g2o="}'
