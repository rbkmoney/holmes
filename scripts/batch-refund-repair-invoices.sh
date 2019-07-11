#!/bin/bash

set -e

CWD="$(dirname $0)"

export LC_ALL=C

source "${CWD}/lib/logging"

# {"invoice":"16vKFsiP5nM","payment":"1","amount":22076.5,"currency":"RUB"}
# ...
BATCH="${1}"

[ -z "${BATCH}" ] && exit 127

for line in $(cat "${BATCH}"); do

  invoice=$(echo "${line}" | jq -r '.invoice')
  payment=$(echo "${line}" | jq -r '.payment')
  amount=$(printf "%.0f" $(echo "${line}" | jq -r '.amount * 100'))
  currency=$(echo "${line}" | jq -r '.currency')

  info "Refunding $(em $amount $currency) @ payment $(em $payment) on invoice $(em $invoice) ..."
  "${CWD}/refund-invoice-payment.sh" "$invoice" "$payment" "$amount" "$currency"
  echo

  sleep 3

  info "Repairing refund @ payment $(em $payment) on $(em $invoice) ..."
  "${CWD}/make-invoice-payment-refunded.sh" "$invoice" "$payment"
  echo

done
