# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.19.51.0.5.ebuild,v 1.2 2009/05/26 16:23:30 flameeyes Exp $

PATCHVER="1.1"
ELF2FLT_VER=""
inherit toolchain-binutils

KEYWORDS="~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

src_unpack() {
	toolchain-binutils_src_unpack
	cd "${S}"
	epatch "${FILESDIR}"/binutils-2.18.50.0.7-mint.patch
	epatch "${FILESDIR}"/binutils-2.18.50.0.7-mint2.patch
	epatch "${FILESDIR}"/binutils-2.19.50.0.1-mint.patch
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
