#!/bin/bash

BATCH="${1}"
[ -z "${BATCH}" ] && exit 127

echo "${BATCH}" | \
  jq '{id, postings:[.postings[] | {from_id:.to_id, to_id:.from_id, amount, currency_sym_code, description}]}'
