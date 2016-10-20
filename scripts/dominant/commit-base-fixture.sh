#!/bin/sh

woorl $* \
    -s damsel/proto/domain_config.thrift \
    http://dominant:8022/v1/domain/repository \
    Repository Commit 0 "$(cat $(dirname $0)/base-fixture.commit.json)"
