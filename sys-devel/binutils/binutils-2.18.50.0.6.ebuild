# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.18.50.0.6.ebuild,v 1.1 2008/04/03 18:07:01 vapier Exp $

EAPI="prefix"

PATCHVER="1.0"
ELF2FLT_VER=""
inherit toolchain-binutils

KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

src_compile() {
	if has noinfo "${FEATURES}" \
	|| ! type -p makeinfo >/dev/null
	then
		# binutils >= 2.17 (accidentally?) requires 'makeinfo'
		export EXTRA_EMAKE="MAKEINFO=true"
	fi

	toolchain-binutils_src_compile
}
