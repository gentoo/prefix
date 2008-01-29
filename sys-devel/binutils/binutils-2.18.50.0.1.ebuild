# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.18.50.0.1.ebuild,v 1.2 2007/09/12 02:19:06 vapier Exp $

EAPI="prefix"

PATCHVER="1.0"
ELF2FLT_VER=""
inherit toolchain-binutils

KEYWORDS="~x86-fbsd ~amd64-linux ~ia64-linux ~x86-linux ~sparc-solaris ~x86-solaris"

src_compile() {
	if has noinfo "${FEATURES}" \
	|| ! type -p makeinfo >/dev/null
	then
		# binutils >= 2.17 (accidentally?) requires 'makeinfo'
		export EXTRA_EMAKE="MAKEINFO=true"
	fi

	toolchain-binutils_src_compile
}
