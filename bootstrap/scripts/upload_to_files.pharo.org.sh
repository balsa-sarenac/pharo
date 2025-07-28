#!/usr/bin/env bash

set -ex

SCRIPTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P)"
. ${SCRIPTS}/envvars.sh

PACKAGED_VERSIONS="latest*.zip"
if [ $(is_release_build) == 1 ]; then
	PACKAGED_VERSIONS="${PACKAGED_VERSIONS} stable*.zip"
fi

destDir="/appli/files.pharo.org/image/${PHARO_SHORT_VERSION}/"
echo "Uploading Images to pharo.files.org/$destDir"

scp -o StrictHostKeyChecking=no -v \
  ${PACKAGED_VERSIONS} \
  ${PHARO_NAME_PREFIX}.build.*.zip \
  ${PHARO_NAME_PREFIX}-metacello.build.*.zip \
    pharo-ci@files.pharo.org:image/${PHARO_SHORT_VERSION}/
