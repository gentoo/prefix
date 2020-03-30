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
	exit 255
fi

mkdir -p "$1"
cd "$1"
mkdir bash-build
cd bash-build

GENTOO_MIRRORS=${GENTOO_MIRRORS:="http://distfiles.gentoo.org/distfiles"}

command_exists() {
	check_cmd="$1"
	command -v $check_cmd >/dev/null 2>&1
}

same_file() {
	file1="$1"
	file2="$2"

	if [ "$(stat -c '%i%d' "$file1" "$file2" | sort -u | wc -l)" -eq 1 ]; then
		return 0
	else
		return 1
	fi
}

if [ ! -e bash-4.2.tar.gz ] ; then
	eerror() { echo "!!! $*" 1>&2; }
	einfo() { echo "* $*"; }

	if [ -z ${FETCH_COMMAND} ] ; then
		# Try to find a download manager, we only deal with wget,
		# curl, FreeBSD's fetch and ftp.
		if command_exists wget; then
			FETCH_COMMAND="wget"
			case "$(wget -h 2>&1)" in
				*"--no-check-certificate"*)
					FETCH_COMMAND="$FETCH_COMMAND --no-check-certificate"
					;;
			esac
		elif command_exists curl; then
			einfo "WARNING: curl doesn't fail when downloading fails, please check its output carefully!"
			FETCH_COMMAND="curl -f -L -O"
		elif command_exists fetch; then
			FETCH_COMMAND="fetch"
		elif command_exists ftp; then
			FETCH_COMMAND="ftp"
			case "${CHOST}" in
				*-cygwin*)
					if same_file "$(command -v ftp)" "$(cygpath -S)/ftp"; then
						FETCH_COMMAND=''
					fi
					;;
			esac
		fi
		if [ -z ${FETCH_COMMAND} ]; then
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
