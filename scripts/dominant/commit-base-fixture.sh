#!/bin/sh

set -e

export CURDIR="$(dirname ${0})"
export LIBDIR="${CURDIR}/../lib"

FIXTURE="$(${LIBDIR}/template.sh ${CURDIR}/base-fixture.commit.json.tpl $*)"

woorl $* \
    -s damsel/proto/domain_config.thrift \
    http://dominant:8022/v1/domain/repository \
    Repository Commit 0 "${FIXTURE}"
