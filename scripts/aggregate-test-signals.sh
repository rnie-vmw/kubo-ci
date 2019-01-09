#!/bin/bash
set -eux

for shipable in ./gcs-*-shipables/*; do
  shipable_signal="$(basename $shipable)"
  new_signal_version="$(tail -1 gcs-${shipable_signal}-shipables/${shipable_signal})"
  is_shipable=true
  for ship_signal in ./gcs-*-shipables/*; do
    signal="$(basename $ship_signal)"
    if ! grep -q "$new_signal_version" "gcs-${signal}-shipables/$signal"; then
      echo "Version \`$new_signal_version\` is not shipable yet"
      echo "Kubo Release has not passed $signal pipeline"
      is_shipable=false
      break
    else
      echo "Version \`$new_signal_version\` passed $signal pipeline"
    fi
  done
  if $is_shipable ; then
    echo "Found shipable version $new_signal_version"
    exit 0
  fi
done
echo "Failed to find a shipable tarball"
exit 1

