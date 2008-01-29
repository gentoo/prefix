# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.18.50.0.3.ebuild,v 1.1 2007/11/04 20:06:23 vapier Exp $

EAPI="prefix"

PATCHVER="1.0"
ELF2FLT_VER=""
inherit toolchain-binutils

KEYWORDS="~x86-fbsd ~amd64-linux ~ia64-linux ~x86-linux ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

src_unpack() {
	toolchain-binutils_src_unpack
	epatch "${FILESDIR}"/2.18-solarisx86_64.patch
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
