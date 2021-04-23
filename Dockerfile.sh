#!/bin/bash
cat <<EOF
FROM $BASE_IMAGE
MAINTAINER Igor Savchuk <i.savchuk@rbkmoney.com>
ENV THRIFT_PORT=8022 \
    CDS=cds \
    SHUMWAY=shumway \
    HELLGATE=hellgate \
    MACHINEGUN=machinegun \
    PROXY_TINKOFF=proxy-tinkoff \
    PROXY_VTB=proxy-vtb \
    PROXY_AGENT=proxy-agent \
    PROXY_MOCKETBANK=proxy-mocketbank \
    PROXY_MOCKET_INSPECTOR=proxy-inspector \
    PROXY_PIMP=pimp
COPY ./damsel/proto    /opt/holmes/damsel/proto
COPY ./cds_proto/proto /opt/holmes/cds_proto/proto
COPY ./binbase-proto/proto /opt/holmes/binbase-proto/proto
COPY ./scripts         /opt/holmes/scripts
COPY ./lib/scripts     /opt/holmes/scripts
CMD epmd
# A bit of magic below to get a proper branch name
# even when the HEAD is detached (Hey Jenkins!
# BRANCH_NAME is available in Jenkins env).
LABEL com.rbkmoney.$SERVICE_NAME.parent=$BASE_IMAGE_NAME \
      com.rbkmoney.$SERVICE_NAME.parent_tag=$BASE_IMAGE_TAG \
      com.rbkmoney.$SERVICE_NAME.build_img=build \
      com.rbkmoney.$SERVICE_NAME.build_img_tag=$BUILD_IMAGE_TAG \
      com.rbkmoney.$SERVICE_NAME.commit_id=$(git rev-parse HEAD) \
      com.rbkmoney.$SERVICE_NAME.commit_number=$(git rev-list --count HEAD) \
      com.rbkmoney.$SERVICE_NAME.branch=$( \
        if [ "HEAD" != $(git rev-parse --abbrev-ref HEAD) ]; then \
          echo $(git rev-parse --abbrev-ref HEAD); \
        elif [ -n "$BRANCH_NAME" ]; then \
          echo $BRANCH_NAME; \
        else \
          echo $(git name-rev --name-only HEAD); \
        fi)
WORKDIR /opt/holmes
EOF
