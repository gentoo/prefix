#!/bin/sh
# Copyright 2006-2018 Gentoo Foundation; Distributed under the GPL v2

# bash installer
#
#  POSIX (?) /bin/sh which doesn't eat most of the stuff in the
# bootstrap-prefix script, among which the most important part:
# dynamic function calling.  So, we need to bootstrap bash outside the
# bootstrap script, which is the purpose of this script.

[ -z "$1" ] && exit -1

mkdir -p "$1"
cd "$1"
mkdir bash-build
cd bash-build

GENTOO_MIRRORS=${GENTOO_MIRRORS:="http://distfiles.gentoo.org/distfiles"}

ftp "${GENTOO_MIRRORS}/bash-4.2.tar.gz"
gzip -d bash-4.2.tar.gz
tar -xf bash-4.2.tar
cd bash-4.2

./configure --prefix="${1}"/usr --disable-nls
make
make install
