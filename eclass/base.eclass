# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/base.eclass,v 1.37 2009/01/18 18:21:08 loki_val Exp $

# @ECLASS: base.eclass
# @MAINTAINER:
# Peter Alfredsen <loki_val@gentoo.org>
#
# Original author Dan Armak <danarmak@gentoo.org>
# @BLURB: The base eclass defines some default functions and variables.
# @DESCRIPTION:
# The base eclass defines some default functions and variables. Nearly
# everything else inherits from here.
#
# NOTE: You must define EAPI before inheriting from base, or the wrong functions
# may be exported.


inherit eutils

case "${EAPI:-0}" in
	2)
		EXPORT_FUNCTIONS src_unpack src_prepare src_configure src_compile src_install
		;;
	*)
		EXPORT_FUNCTIONS src_unpack src_compile src_install
		;;
esac

DESCRIPTION="Based on the $ECLASS eclass"

# @FUNCTION: base_src_unpack
# @USAGE: [ unpack ] [ patch ] [ autopatch ] [ all ]
# @DESCRIPTION:
# The base src_unpack function, which is exported. If no argument is given,
# "all" is assumed if EAPI!=2, "unpack" if EAPI=2.
base_src_unpack() {

	debug-print-function $FUNCNAME "$@"

	if [ -z "$1" ] ; then
		case "${EAPI:-0}" in
			2)
				base_src_util unpack
				;;
			*)
				base_src_util all
				;;
		esac
	else
		base_src_util $@
	fi
}

# @FUNCTION: base_src_prepare
# @DESCRIPTION:
# The base src_prepare function, which is exported when EAPI=2. Performs
# "base_src_util autopatch".
base_src_prepare() {

	debug-print-function $FUNCNAME "$@"

	base_src_util autopatch
}

# @FUNCTION: base_src_util
# @USAGE: [ unpack ] [ patch ] [ autopatch ] [ all ]
# @DESCRIPTION:
# The base_src_util function is the grunt function for base src_unpack
# and base src_prepare.
base_src_util() {

	debug-print-function $FUNCNAME "$@"

	cd "${WORKDIR}"

	while [ "$1" ]; do

	case $1 in
		unpack)
			debug-print-section unpack
			if [ ! -z "$A" ] ; then
				unpack ${A}
			fi
			;;
		patch)
			debug-print-section patch
			cd "${S}"
			epatch "${FILESDIR}/${P}-gentoo.diff"
			;;
		autopatch)
			debug-print-section autopatch
			debug-print "$FUNCNAME: autopatch: PATCHES=$PATCHES, PATCHES1=$PATCHES1"
			cd "${S}"
			if [[ ${#PATCHES[@]} -gt 1 ]] ; then
				for x in "${PATCHES[@]}"; do
					debug-print "$FUNCNAME: autopatch: patching from ${x}"
					epatch "${x}"
				done
			else
				for x in ${PATCHES} ${PATCHES1}; do
					debug-print "$FUNCNAME: autopatch: patching from ${x}"
					epatch "${x}"
				done
			fi
			;;
		all)
			debug-print-section all
			base_src_util unpack autopatch
			;;
		esac

	shift
	done

}

# @FUNCTION: base_src_configure
# @DESCRIPTION:
# The base src_prepare function, which is exported when EAPI=2. Performs
# "base_src_work configure".
base_src_configure() {

	debug-print-function $FUNCNAME "$@"

	base_src_work configure
}

# @FUNCTION: base_src_compile
# @USAGE: [ configure ] [ make ] [ all ]
# @DESCRIPTION:
# The base src_compile function, which is exported. If no argument is given,
# "all" is assumed if EAPI!=2, "make" if EAPI=2.
base_src_compile() {

	debug-print-function $FUNCNAME "$@"

	if [ -z "$1" ]
	then
		case "${EAPI:-0}" in
			2)
				base_src_work make
				;;
			*)
				base_src_work all
				;;
		esac
	else
		base_src_work $@
	fi
}

# @FUNCTION: base_src_work
# @USAGE: [ configure ] [ make ] [ all ]
# @DESCRIPTION:
# The base_src_work function is the grunt function for base src_configure
# and base src_compile.
base_src_work() {

	debug-print-function $FUNCNAME "$@"

	cd "${S}"

	while [ "$1" ]; do

	case $1 in
		configure)
			debug-print-section configure
			if [[ -x ${ECONF_SOURCE:-.}/configure ]]
			then
				econf || die "died running econf, $FUNCNAME:configure"
			fi
			;;
		make)
			debug-print-section make
			if [ -f Makefile ] || [ -f GNUmakefile ] || [ -f makefile ]
			then
				emake || die "died running emake, $FUNCNAME:make"
			fi
			;;
		all)
			debug-print-section all
			base_src_work configure make
			;;
	esac

	shift
	done

}

# @FUNCTION: base_src_install
# @USAGE: [ make ] [ all ]
# @DESCRIPTION:
# The base src_install function, which is exported. If no argument is given,
# "all" is assumed.
base_src_install() {

	debug-print-function $FUNCNAME "$@"
	[ -z "$1" ] && base_src_install all

	cd "${S}"

	while [ "$1" ]; do

	case $1 in
		make)
			debug-print-section make
			make DESTDIR="${D}" install || die "died running make install, $FUNCNAME:make"
			;;
		all)
			debug-print-section all
			base_src_install make
			;;
	esac

	shift
	done

}
