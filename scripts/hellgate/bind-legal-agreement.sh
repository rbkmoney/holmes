#!/bin/bash

SCRIPTNAME=$(basename $0)

bind_legal_agreement () {
    woorl $6 \
        -s damsel/proto/payment_processing.thrift \
        http://${HELLGATE}:${THRIFT_PORT}/v1/processing/partymgmt \
        PartyManagement BindContractLegalAgreemnet "$1" "$2" "$3" \
            "{\"legal_agreement_id\":${4},\"signed_at\":${5}}"
}

case "$1" in
    ""|"-h"|"--help" )
        echo -e "Bind legal agreement to a contract given its ID."
        echo
        echo -e "Usage: ${SCRIPTNAME} party_id contract_id agreement_id agreement_date [woorl_opts]"
        echo -e "  party_id        Party ID (string)."
        echo -e "  contract_id     Contract ID (number)."
        echo -e "  agreement_id    Agreement ID, e.g. registered contract number (string)."
        echo -e "  agreement_date  Date and time when agreement was signed (rfc3339 string)."
        echo -e "  -h, --help      Show this help message."
        echo
        echo -e "More information:"
        echo -e "  https://github.com/rbkmoney/damsel/blob/4018c41/proto/payment_processing.thrift"
        exit 0
        ;;
    * )
        USERINFO="{\"id\":\"${SCRIPTNAME}\",\"type\":{\"service_user\":{}}}"
        PARTY_ID="\"$1\""
        shift 1
        CONTRACT_ID="$1"
        shift 1
        AGREEMENT_ID="\"$1\""
        shift 1
        AGREEMENT_DATE="\"$1\""
        shift 1
        bind_legal_agreement "$USERINFO" "$INVOICE_ID" "$CONTRACT_ID" "$AGREEMENT_ID" "$AGREEMENT_DATE" "$*"
        ;;
esac
