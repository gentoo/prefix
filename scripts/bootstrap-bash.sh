#!/bin/sh
# Copyright 2006-2018 Gentoo Foundation; Distributed under the GPL v2

# bash installer
#
#  POSIX (?) /bin/sh which doesn't eat most of the stuff in the
# bootstrap-prefix script, among which the most important part:
# dynamic function calling.  So, we need to bootstrap bash outside the
# bootstrap script, which is the purpose of this script.

if [ -z "$1" ] ; then
	echo "usage: ${0} <location>" > /dev/stderr
	exit -1
fi

mkdir -p "$1"
cd "$1"
mkdir bash-build
cd bash-build

GENTOO_MIRRORS=${GENTOO_MIRRORS:="http://distfiles.gentoo.org/distfiles"}

if [ ! -e bash-4.2.tar.gz ] ; then
	eerror() { echo "!!! $*" 1>&2; }
	einfo() { echo "* $*"; }

	if [ -z ${FETCH_COMMAND} ] ; then
		# Try to find a download manager, we only deal with wget,
		# curl, FreeBSD's fetch and ftp.
		if [ x$(type -t wget) == "xfile" ] ; then
			FETCH_COMMAND="wget"
			[ $(wget -h) == *"--no-check-certificate"* ] && FETCH_COMMAND+=" --no-check-certificate"
		elif [ x$(type -t curl) == "xfile" ] ; then
			einfo "WARNING: curl doesn't fail when downloading fails, please check its output carefully!"
			FETCH_COMMAND="curl -f -L -O"
		elif [ x$(type -t fetch) == "xfile" ] ; then
			FETCH_COMMAND="fetch"
		elif [ x$(type -t ftp) == "xfile" ] &&
			 [ ${CHOST} != *-cygwin* || ! $(type -P ftp) -ef $(cygpath -S)/ftp ] ; then
			FETCH_COMMAND="ftp"
		else
			eerror "no suitable download manager found (need wget, curl, fetch or ftp)"
			eerror "could not download ${1##*/}"
			eerror "download the file manually, and put it in ${PWD}"
			exit 1
		fi
	fi
	${FETCH_COMMAND} "${GENTOO_MIRRORS}/bash-4.2.tar.gz" < /dev/null
fi

gzip -d bash-4.2.tar.gz
tar -xf bash-4.2.tar
cd bash-4.2

./configure --prefix="${1}"/usr --disable-nls
make
make install
