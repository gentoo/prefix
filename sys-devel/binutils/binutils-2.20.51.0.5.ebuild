# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.20.51.0.5.ebuild,v 1.1 2010/01/16 09:16:32 vapier Exp $

PATCHVER="1.0"
ELF2FLT_VER=""
inherit toolchain-binutils

KEYWORDS="~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

src_unpack() {
	toolchain-binutils_src_unpack
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-2.20.51.0.1-linux-x86-on-amd64.patch
	epatch "${FILESDIR}"/${PN}-2.20.51.0.3-mint.patch
	epatch "${FILESDIR}"/${PN}-2.19.50.0.1-mint.patch
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
