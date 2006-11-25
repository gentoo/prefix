# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.17.50.0.6.ebuild,v 1.3 2006/11/15 20:30:18 swegener Exp $

EAPI="prefix"

PATCHVER="1.1"
UCLIBC_PATCHVER="1.0"
ELF2FLT_VER=""
inherit autotools toolchain-binutils

# ARCH - packages to test before marking
KEYWORDS="~amd64"

# make sure the headers will be regenerated
EXTRA_ECONF="${EXTRA_ECONF} --enable-maintainer-mode"
#workaround
MAKEOPTS=-j1
src_unpack() {
	toolchain-binutils_src_unpack
	cd ${S}
	for dir in bfd gas ld opcodes
	do
		pushd ${dir} >/dev/null
		eautoreconf
		popd >/dev/null
	done
}
