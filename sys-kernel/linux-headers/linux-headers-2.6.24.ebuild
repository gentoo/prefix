# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-kernel/linux-headers/linux-headers-2.6.24.ebuild,v 1.4 2008/05/12 16:14:34 corsair Exp $

EAPI="prefix"

ETYPE="headers"
H_SUPPORTEDARCH="alpha amd64 arm cris hppa m68k mips ia64 ppc ppc64 s390 sh sparc x86"
inherit kernel-2
detect_version

PATCH_VER="1"
SRC_URI="mirror://gentoo/gentoo-headers-base-${PV}.tar.bz2"
[[ -n ${PATCH_VER} ]] && SRC_URI="${SRC_URI} mirror://gentoo/gentoo-headers-${PV}-${PATCH_VER}.tar.bz2"

KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux"

DEPEND=""
RDEPEND=""

S=${WORKDIR}/gentoo-headers-base-${PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
	[[ -n ${PATCH_VER} ]] && EPATCH_SUFFIX="patch" epatch "${WORKDIR}"/${PV}
}

src_install() {
	kernel-2_src_install
	cd "${ED}"
	egrep -r \
		-e '[[:space:]](asm|volatile|inline)[[:space:](]' \
		-e '\<([us](8|16|32|64))\>' \
		.
	headers___fix $(find -type f)
}

src_test() {
	emake -j1 ARCH=$(tc-arch-kernel) headers_check || die
}
