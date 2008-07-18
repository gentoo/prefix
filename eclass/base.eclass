# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/base.eclass,v 1.34 2008/07/17 09:49:14 pva Exp $

# @ECLASS: base.eclass
# @MAINTAINER:
# ???
#
# Original author Dan Armak <danarmak@gentoo.org>
# @BLURB: The base eclass defines some default functions and variables.
# @DESCRIPTION:
# The base eclass defines some default functions and variables. Nearly
# everything else inherits from here.


inherit eutils

DESCRIPTION="Based on the $ECLASS eclass"

# @FUNCTION: base_src_unpack
# @USAGE: [ unpack ] [ patch ] [ autopatch ] [ all ]
# @DESCRIPTION:
# The base src_unpack function, which is exported. If no argument is given,
# "all" is assumed.
base_src_unpack() {

	debug-print-function $FUNCNAME $*
	[ -z "$1" ] && base_src_unpack all

	cd "${WORKDIR}"

	while [ "$1" ]; do

	case $1 in
		unpack)
			debug-print-section unpack
			unpack ${ONLYA:-${A}}
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
			if [[ ${#PATCHES[@]} -gt 1 ]]; then
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
			base_src_unpack unpack autopatch
			;;
		esac

	shift
	done

}

# @FUNCTION: base_src_compile
# @USAGE: [ configure ] [ make ] [ all ]
# @DESCRIPTION:
# The base src_compile function, which is exported. If no argument is given,
# "all" is asasumed.
base_src_compile() {

	debug-print-function $FUNCNAME $*
	[ -z "$1" ] && base_src_compile all

	cd "${S}"

	while [ "$1" ]; do

	case $1 in
		configure)
			debug-print-section configure
			econf || die "died running econf, $FUNCNAME:configure"
			;;
		make)
			debug-print-section make
			emake || die "died running emake, $FUNCNAME:make"
			;;
		all)
			debug-print-section all
			base_src_compile configure make
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

	debug-print-function $FUNCNAME $*
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

EXPORT_FUNCTIONS src_unpack src_compile src_install
