#!/bin/bash

set -o errexit
set -o pipefail
set -o errtrace

CWD="$(dirname $0)"
SCRIPTNAME="$(basename $0)"

source "${CWD}/lib/logging"

# Actual work is going here

INVOICE="${1}"
PAYMENT="${2}"

case ${INVOICE} in
  ""|"-h"|"--help" )
    echo -ne "Given ID of an invoice and a failed payment make it look like the payment processed successfully. "
    echo
    echo -e "Usage: ${SCRIPTNAME} invoice_id payment_id [--force]"
    echo -e "  invoice_id      Invoice ID (string)."
    echo -e "  payment_id      Payment ID (string)."
    echo -e "  -h, --help      Show this help message."
    echo
    echo -e "More information:"
    echo -e "  https://github.com/rbkmoney/damsel/blob/master/proto/payment_processing.thrift"
    exit 0
    ;;
  * )
    ;;
esac

INVOICE_EVENTS=$("${CWD}/hellgate/get-invoice-events.sh" "${INVOICE}")

LAST_PAYMENT_CHANGE=$(
  echo "${INVOICE_EVENTS}" |
    jq ".[] | .payload.invoice_changes | .[] | select(.invoice_payment_change.id == \"${PAYMENT}\")" |
    jq --slurp '.[-1]'
)

ARE_ALL_PAYMENTS_FAILED=$(
  echo "${INVOICE_EVENTS}" |
    jq ".[] | .payload.invoice_changes | .[] | .invoice_payment_change | select(.payload |
        has(\"invoice_payment_status_changed\"))" |
    jq --slurp 'group_by(.id) | .[] | .[-1].payload.invoice_payment_status_changed.status | keys |
        all( . == "failed" )'
)

if [ "${LAST_PAYMENT_CHANGE}" = "null" ]; then
  err "Unknown payment ${PAYMENT}"
fi

LAST_PAYMENT_STATUS=$(
  echo "${LAST_PAYMENT_CHANGE}" | jq '.invoice_payment_change.payload.invoice_payment_status_changed.status'
)
if [ \
  "$(echo "${LAST_PAYMENT_STATUS}" | jq 'has("failed")')" != "true" \
]; then
  err "The payment ${PAYMENT} does not failed."
fi

if [ "${ARE_ALL_PAYMENTS_FAILED}" != "true" ]; then
  err "No all payments in this invoice are failed"
fi

PAYMENT_ACCOUNTER_PLAN=$("${CWD}"/get-posting-plan.sh "${INVOICE}.${PAYMENT}")

if [ \
  $(echo "${PAYMENT_ACCOUNTER_PLAN}" | jq '.batch_list | length') != "1" \
]; then
  err "It seems like the payment has an unexpected postings plan configuration"
fi

PLAN_BATCH=$(echo "${PAYMENT_ACCOUNTER_PLAN}" | jq ".batch_list | .[0]")

SESSIONS_NUMBER=$(
  echo "${INVOICE_EVENTS}" |
    jq ".[] | .payload.invoice_changes | .[] | select(.invoice_payment_change.id == \"${PAYMENT}\") |
        select(.invoice_payment_change.payload | has(\"invoice_payment_session_change\")) |
        .invoice_payment_change.payload.invoice_payment_session_change.payload |
        select(has(\"session_started\"))"
    | jq --slurp 'length'
)

if [ \
  "${SESSIONS_NUMBER}" != "1" \
]; then
  err "It seems like the payment has multiple sessions"
fi

PAYMENT_SESSION_EVENTS=$(
  echo "${INVOICE_EVENTS}" |
    jq ".[] | .payload.invoice_changes | .[] | select(.invoice_payment_change.id == \"${PAYMENT}\") |
        select(.invoice_payment_change.payload | has(\"invoice_payment_session_change\"))" |
    jq --slurp '.'
)

NEW_SESSION_FINISH=$(cat <<END
  {
    "invoice_payment_change": {
      "id": "${PAYMENT}",
      "payload": {
        "invoice_payment_session_change": {
          "target": {
            "processed": []
          },
          "payload": {
            "session_finished": {
              "result": {
                "succeeded": []
              }
            }
          }
        }
      }
    }
  }
END
)

NEW_INVOICE_FINISH=$(cat <<END
  {
    "invoice_payment_change": {
      "id": "${PAYMENT}",
      "payload": {
        "invoice_payment_status_changed": {
          "status": {
            "processed": {}
          }
        }
      }
    }
  }
  {
    "invoice_payment_change": {
      "id": "${PAYMENT}",
      "payload": {
        "invoice_payment_status_changed": {
          "status": {
            "captured": {}
          }
        }
      }
    }
  }
  {
    "invoice_status_changed": {
      "status": {
        "paid": {}
      }
    }
  }
END
)

PAYMENT_SESSION_EVENTS_WITHOUT_FINISH=$(
  echo "${PAYMENT_SESSION_EVENTS}" |
  jq '
    .[] |
      select(.invoice_payment_change.payload.invoice_payment_session_change.payload | has("session_finished") | not)
  '
)

NEW_EVENTS=$(
  (
    echo "${PAYMENT_SESSION_EVENTS_WITHOUT_FINISH}" &&
    echo "${NEW_SESSION_FINISH}" &&
    echo "${NEW_INVOICE_FINISH}"
  ) | jq --slurp '.'
)

# First we need to explicitly make invoice failed again. Amen.
"${CWD}/fail-machine.sh" "${INVOICE}"

function warn_before_accounter {
  warn "You should manually check invoice state and apply accouter changes if it is necessary!"
}
trap warn_before_accounter ERR

# Then we should stuff it with previously reconstructed history
"${CWD}/repair-invoice.sh" "${INVOICE}" "${NEW_EVENTS}" --force

function warn_before_end {
  warn "You should manually check accouter state!"
}
trap warn_before_accounter ERR

"${CWD}/submit-posting-plan.sh" "${INVOICE}.${PAYMENT}.repair" "${PLAN_BATCH}"
