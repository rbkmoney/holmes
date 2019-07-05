#!/bin/bash

CWD="$(dirname $0)"
DAMSEL="${CWD}/../damsel"
SCRIPTNAME="$(basename $0)"

source "${CWD}/lib/logging"

USAGE=$(cat <<EOF
Usage: ${SCRIPTNAME} [--force] [--set-timeout SEC | --set-deadline TS | --unset-timer | --remove] invoice-id invoice-changes
  Repairs an invoice and stuffs it with the user-provided list of invoice changes.
  invoice-id           Invoice ID (string)
  invoice-changes      Invoice changes (json array)
  --set-timeout        To set timer to this number of seconds
  --set-deadline       To set timer to this time instant (RFC3339 timestamp)
  --unset-timer        To unset any pending timer (not an error if no timer is set)
  --force              To force appending changeset (which in effect turns state transitions validation off)

More information:
  https://github.com/rbkmoney/damsel
EOF
)

function usage {
    echo "${USAGE}"
    exit 127
}

getopt -T
[ $? != 4 ] && { err "Please provide modern GNU getopt implementation."; }

TEMP=$(getopt -o "" --long force,set-timeout:,set-deadline:,unset-timer -n "${SCRIPTNAME}" -- "$@")
[ $? != 0 ] && usage

eval set -- "${TEMP}"
ACTION="{}"
PARAMS="{}"
while true; do
  case "$1" in
    --force        ) PARAMS='{"validate_transitions":false}'                            ; shift 1 ;;
    --set-timeout  ) ACTION="{\"timer\":{\"set_timer\":{\"timer\":{\"timeout\":$2}}}}"  ; shift 2 ;;
    --set-deadline ) ACTION="{\"timer\":{\"set_timer\":{\"timer\":{\"deadline\":$2}}}}" ; shift 2 ;;
    --unset-timer  ) ACTION="{\"timer\":{\"unset_timer\":{}}}"                          ; shift 1 ;;
    --             ) shift 1 ; break ;;
    *              ) break ;;
  esac
done

INVOICE="${1}"
[ -z "${INVOICE}" ] && usage
INVOICE_CHANGES="${2}"
[ -z "${INVOICE_CHANGES}" ] && usage

[ -f woorlrc ] && source woorlrc

USERINFO='{"id":"woorl","type":{"service_user":{}}}'

"${WOORL:-woorl}" \
    -s "${DAMSEL}/proto/payment_processing.thrift" \
    "http://${HELLGATE:-hellgate}:8022/v1/processing/invoicing" \
    Invoicing Repair "${USERINFO}" "\"${INVOICE}\"" "${INVOICE_CHANGES}" "${ACTION}" "${PARAMS}"
