#!/bin/sh

set -e

CWD="$(dirname $0)"
DAMSEL="${CWD}/../../damsel"
SCRIPTNAME=$(basename $0)

export CURDIR="$(dirname ${0})"
export LIBDIR="${CURDIR}/../lib"

case "$1" in
    "-h"|"--help" )
        echo -e "Estabilish basic system domain configuration from the ground up. Useful for setting up" \
                "fresh development environment."
        echo
        echo -e "Usage: ${SCRIPTNAME} [woorl_opts]"
        echo -e "  -h, --help      help"
        echo
        echo -e "More information:"
        echo -e "  https://github.com/rbkmoney/damsel/blob/a603319/proto/payment_processing.thrift"
        exit 0
        ;;
    * )
        FIXTURE=$("${LIBDIR}/template.sh" "${CURDIR}/base-fixture.commit.json.tpl" $*)
        "${WOORL:-woorl}" $* \
            -s "${DAMSEL}/proto/domain_config.thrift" \
            "http://${DOMINANT:-dominant}:8022/v1/domain/repository" \
            Repository Commit 0 "${FIXTURE}"
esac
