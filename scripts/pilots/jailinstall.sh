#!/usr/bin/env bash

MAGIC=/XXXXXXXXXXXXXGentooXXXXXXXXX
IMG=/var/tmp/jail/image
TARGET=/var/tmp/jail/install

PATH=${PWD}:${PATH}

cd ${IMG}
for f in $(find ${MAGIC#/}) ; do
	target=${TARGET}${f#${MAGIC#/}}
	mkdir -p $(dirname ${target}) >& /dev/null
	if [[ -f ${IMG}/${f} ]] ; then
		jailer ${IMG}/${f} ${target} ${MAGIC} ${TARGET}
	fi
done
