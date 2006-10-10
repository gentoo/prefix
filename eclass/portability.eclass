# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/portability.eclass,v 1.8 2006/03/08 20:08:13 flameeyes Exp $
#
# Author: Diego Pettenò <flameeyes@gentoo.org>
#
# This eclass is created to avoid using non-portable GNUisms inside ebuilds
#
# NB:  If you add anything, please comment it!

# treecopy orig1 orig2 orig3 .... dest
#
# mimic cp --parents copy, but working on BSD userland as well
treecopy() {
	dest=${!#}
	files_count=$#

	while(( $# > 1 )); do
		dirstruct=$(dirname "$1")
		mkdir -p "${dest}/${dirstruct}"
		cp -pPR "$1" "${dest}/${dirstruct}"

		shift
	done
}

# seq min max
#
# compatibility function that mimes seq command if not available
seq() {
	local p=$(type -P seq)

	case $# in
		1) min=1  max=$1 step=1  ;;
		2) min=$1 max=$2 step=1  ;;
		3) min=$1 max=$3 step=$2 ;;
		*) die "seq called with wrong number of arguments" ;;
	esac

	if [[ -z ${p} ]] ; then
		local reps
		# BSD userland
		if [[ ${step} != 0 ]]; then
			reps=$(( ($max-$min) / $step +1 ))
		else
			reps=0
		fi

		jot $reps $min $max $step
	else
		"${p}" $min $step $max
	fi
}

# Gets the linker flag to link to dlopen() function
dlopen_lib() {
	if [[ ${ELIBC} != *BSD ]]; then
		echo "-ldl"
	fi
}

# Gets the home directory for the specified user
# it's a wrap around egetent as the position of the home directory in the line
# varies depending on the os used.
#
# To use that, inherit eutils, not portability!
egethome() {
	ent=$(egetent passwd $1)

	case ${CHOST} in
	*-darwin*|*-freebsd*|*-dragonfly*)
		# Darwin, OSX, FreeBSD and DragonFly use position 9 to store homedir
		echo ${ent} | cut -d: -f9
		;;
	*)
		# Linux, NetBSD and OpenBSD use position 6 instead
		echo ${ent} | cut -d: -f6
		;;
	esac
}

# Gets the shell for the specified user
# it's a wrap around egetent as the position of the home directory in the line
# varies depending on the os used.
#
# To use that, inherit eutils, not portability!
egetshell() {
	ent=$(egetent passwd "$1")

	case ${CHOST} in
	*-darwin*|*-freebsd*|*-dragonfly*)
		# Darwin, OSX, FreeBSD and DragonFly use position 9 to store homedir
		echo ${ent} | cut -d: -f10
		;;
	*)
		# Linux, NetBSD and OpenBSD use position 6 instead
		echo ${ent} cut -d: -f7
		;;
	esac
}

# Returns true if specified user has a shell that precludes logins
# on whichever operating system.
is-login-disabled() {
	shell=$(egetshell "$1")

	case ${shell} in
		/bin/false|/usr/bin/false|/sbin/nologin|/usr/sbin/nologin)
			return 0 ;;
		*)
			return 1 ;;
	esac
}

# Gets the name of the BSD-ish make command (pmake from NetBSD)
#
# This will return make (provided by system packages) for BSD userlands,
# or bsdmake for Darwin userlands and pmake for the rest of userlands,
# both of which are provided by sys-devel/pmake package.
#
# Note: the bsdmake for Darwin userland is with compatibility with MacOSX
# default name.
get_bmake() {
	if [[ ${USERLAND} == *BSD ]]; then
		echo make
	elif [[ ${USERLAND} == "Darwin" ]]; then
		echo bsdmake
	else
		echo pmake
	fi
}
