# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.18.50.0.9.ebuild,v 1.1 2008/09/21 07:29:23 vapier Exp $

PATCHVER="1.0"
ELF2FLT_VER=""
inherit toolchain-binutils

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

src_unpack() {
	tc-binutils_unpack
	cd "${S}"
	epatch "${FILESDIR}"/binutils-2.18.50.0.7-mint.patch
	epatch "${FILESDIR}"/binutils-2.18.50.0.7-mint2.patch
	epatch "${FILESDIR}"/${P}-reloc.patch
	cd gas
	epatch "${FILESDIR}"/${P}-solaris-eh-frame.patch
}

src_compile() {
	if has noinfo "${FEATURES}" \
	|| ! type -p makeinfo >/dev/null
	then
		# binutils >= 2.17 (accidentally?) requires 'makeinfo'
		export EXTRA_EMAKE="MAKEINFO=true"
	fi

	toolchain-binutils_src_compile
}
