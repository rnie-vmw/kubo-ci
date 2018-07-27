#!/usr/bin/env bash

set -eu -o pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

export DEPLOYMENT_NAME="${DEPLOYMENT_NAME:="ci-service"}"
KUBO_ENVIRONMENT_DIR="${ROOT}/environment"

export GOPATH="${ROOT}/git-kubo-ci"

main() {
  source "${ROOT}/git-kubo-ci/scripts/lib/utils.sh"
  setup_env "${KUBO_ENVIRONMENT_DIR}"

  BOSH_ENV="${KUBO_ENVIRONMENT_DIR}" source "${ROOT}/git-kubo-deployment/bin/set_bosh_environment"
  local tmpfile="$(mktemp)" && echo "CONFIG=${tmpfile}"
  "${ROOT}/git-kubo-ci/scripts/generate-test-config.sh" ${KUBO_ENVIRONMENT_DIR} ${DEPLOYMENT_NAME} > "${tmpfile}"

  CONFIG="${tmpfile}" ginkgo -r -progress "${ROOT}/git-kubo-ci/src/tests/upgrade-tests/"
}

main
