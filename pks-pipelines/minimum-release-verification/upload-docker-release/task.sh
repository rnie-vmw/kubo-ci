#!/bin/bash

set -euxo pipefail

source git-kubo-ci/pks-pipelines/minimum-release-verification/utils/all-env.sh

pushd git-pks-docker-bosh-release
  bosh create-release --version="${DOCKER_GIT_SHA}" --tarball pipeline.tgz
  bosh upload-release pipeline.tgz
popd
