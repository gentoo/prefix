#!/bin/sh

# *BSD bash installer
#
# FreeBSD and OpenBSD come with some POSIX (?) /bin/sh which doesn't eat
# most of the stuff in the bootstrap-prefix script, among which the most
# important part: dynamic function calling.  So, we need to bootstrap
# bash outside the bootstrap script, which is the purpose of this
# script.

[ -z "$1" ] && exit -1

cd "$1"
mkdir bash-build
cd bash-build

ftp http://ftp.gnu.org/gnu/bash/bash-3.2.tar.gz
gzip -d bash-3.2.tar.gz
tar -xf bash-3.2.tar
cd bash-3.2

./configure --prefix="${1}"/usr --disable-nls
make
make install
