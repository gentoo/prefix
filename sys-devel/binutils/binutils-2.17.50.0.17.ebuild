# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.17.50.0.17.ebuild,v 1.3 2007/07/26 04:40:51 vapier Exp $

EAPI="prefix"

PATCHVER="1.1"
ELF2FLT_VER=""
inherit toolchain-binutils eutils

KEYWORDS="~amd64-linux ~sparc-solaris ~x86-solaris"

src_compile() {
	if has noinfo "${FEATURES}" \
	|| ! type -p makeinfo >/dev/null
	then
		# binutils >= 2.17 (accidentally?) requires 'makeinfo'
		export EXTRA_EMAKE="MAKEINFO=true"
	fi

	toolchain-binutils_src_compile
}

src_unpack() {
	toolchain-binutils_src_unpack
	if [[ ${CHOST} == *-interix* ]] ; then
		cd "${S}"
		epatch "${FILESDIR}"/binutils-2.17-interix.patch
	fi
}
