#!/bin/bash
#
# This little guy makes an invoice paid again.
#

set -e

INVOICE="${1}"
PAYMENT="${2:-1}"

case ${INVOICE} in
  ""|"-h"|"--help" )
    echo -ne "Given ID of an invoice make it look like it was paid already."
    echo
    echo
    echo -e "Usage: ${SCRIPTNAME} invoice_id [payment_id]"
    echo -e "  invoice_id      Invoice ID (string)."
    echo -e "  -h, --help      Show this help message."
    echo
    echo -e "More information:"
    echo -e "  https://github.com/rbkmoney/damsel/blob/master/proto/payment_processing.thrift"
    exit 0
    ;;
  * )
    ;;
esac

CHANGES=$(cat <<END
  [
    {
      "invoice_status_changed": {
        "status": {
          "paid": []
        }
      }
    }
  ]
END
)

# First we need to explicitly make invoice failed again. Amen.
./fail-machine.sh "${INVOICE}"

# Then we should stuff it with previously reconstructed history
./repair-invoice.sh "${INVOICE}" "${CHANGES}"
