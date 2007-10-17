# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.18-r1.ebuild,v 1.8 2007/10/16 14:26:37 angelos Exp $

EAPI="prefix"

PATCHVER="1.5"
ELF2FLT_VER=""
inherit toolchain-binutils

KEYWORDS="~amd64 ~ia64 ~sparc-solaris ~x86-solaris"

src_unpack() {
	toolchain-binutils_src_unpack
	# disable regeneration of info pages #193364
	touch "${S}"/bfd/elf.c
}
