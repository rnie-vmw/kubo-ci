#!/usr/bin/env bash

set -eu
if [[ -f source-json/source.json ]]; then
    source git-kubo-ci/scripts/set-bosh-env source-json/source.json
else
    source git-kubo-ci/scripts/set-bosh-env source-json/metadata
fi

wget --quiet https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-${bosh_cli_version}-linux-amd64 --output-document="/usr/bin/bosh"
chmod +x /usr/bin/bosh


VM=""
if [ ${IAAS} == "gcp" ]; then
  IAAS="google"
  VM="kvm"
elif [ ${IAAS} == "aws" ]; then
  VM="xen-hvm"
elif [ ${IAAS} == "vsphere" ]; then
  VM="esxi"
elif [ ${IAAS} == "azure" ]; then
  VM="hyperv"
elif [ ${IAAS} == "openstack" ]; then
  VM="kvm"
fi


stemcell_version="$(bosh int --path=/stemcells/0/version git-kubo-release/manifests/cfcr.yml)"
stemcell_line="$(bosh int --path=/stemcells/0/os git-kubo-release/manifests/cfcr.yml)"

# 250.17 starts using a new directory structure for stemcells...
function version_gt() {
  test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1";
}

if version_gt ${stemcell_version} 250.17; then
  bosh upload-stemcell --name="bosh-${IAAS}-${VM}-${stemcell_line}-go_agent" --version="${stemcell_version}" "https://s3.amazonaws.com/bosh-core-stemcells/${stemcell_version}/bosh-stemcell-${stemcell_version}-${IAAS}-${VM}-${stemcell_line}-go_agent.tgz"
else
  bosh upload-stemcell --name="bosh-${IAAS}-${VM}-${stemcell_line}-go_agent" --version="${stemcell_version}" "https://s3.amazonaws.com/bosh-core-stemcells/${IAAS}/bosh-stemcell-${stemcell_version}-${IAAS}-${VM}-${stemcell_line}-go_agent.tgz"
fi

if [[ -d alternate-stemcell ]]; then
  files=( alternate-stemcell/*stemcell*.tgz )
  bosh upload-stemcell "${files[0]}"
fi
