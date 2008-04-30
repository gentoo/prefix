#!/bin/sh

# *BSD bash installer
#
# FreeBSD and OpenBSD come with some POSIX (?) /bin/sh which doesn't eat
# most of the stuff in the bootstrap-prefix script, among which the most
# important part: dynamic function calling.  So, we need to bootstrap
# bash outside the bootstrap script, which is the purpose of this
# script.
# This script also runs on Interix, provided that you put the sources in
# place in the chosen prefix ($1)

[ -z "$1" ] && exit -1

cd "$1"
mkdir bash-build
cd bash-build

# If the sources are in the target dir, use them, this comes in handy on
# platforms that have a malfunctioning ftp, like Interix.
if [ -f "$1"/bash-3.2.tar.gz ] ; then
	cp "$1"/bash-3.2.tar.gz .
else
	ftp http://ftp.gnu.org/gnu/bash/bash-3.2.tar.gz
fi
gzip -d bash-3.2.tar.gz
tar -xf bash-3.2.tar
cd bash-3.2

./configure --prefix="${1}"/usr --disable-nls
make
make install
