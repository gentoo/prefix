# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/base.eclass,v 1.31 2007/09/12 20:05:33 betelgeuse Exp $
#
# Author Dan Armak <danarmak@gentoo.org> (nowadays retired)
#
# The base eclass defines some default functions and variables. Nearly everything
# else inherits from here.

inherit eutils

DESCRIPTION="Based on the $ECLASS eclass"

base_src_unpack() {

	debug-print-function $FUNCNAME $*
	[ -z "$1" ] && base_src_unpack all

	cd ${WORKDIR}

	while [ "$1" ]; do

	case $1 in
		unpack)
			debug-print-section unpack
			unpack ${A}
			;;
		patch)
			debug-print-section patch
			cd ${S}
			epatch ${FILESDIR}/${P}-gentoo.diff
			;;
		autopatch)
			debug-print-section autopatch
			debug-print "$FUNCNAME: autopatch: PATCHES=$PATCHES, PATCHES1=$PATCHES1"
			cd ${S}
			for x in $PATCHES $PATCHES1; do
				debug-print "$FUNCNAME: autopatch: patching from ${x}"
				epatch ${x}
			done
			;;
		all)
			debug-print-section all
			base_src_unpack unpack autopatch
			;;
		esac

	shift
	done

}

base_src_compile() {

	debug-print-function $FUNCNAME $*
	[ -z "$1" ] && base_src_compile all

	cd ${S}

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

base_src_install() {

	debug-print-function $FUNCNAME $*
	[ -z "$1" ] && base_src_install all

	cd ${S}

	while [ "$1" ]; do

	case $1 in
		make)
			debug-print-section make
			make DESTDIR=${D} install || die "died running make install, $FUNCNAME:make"
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
