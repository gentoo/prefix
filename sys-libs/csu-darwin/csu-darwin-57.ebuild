# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/csu/csu-57.ebuild,v 1.1 2005/05/19 21:20:36 kito Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Darwin Csu"
HOMEPAGE="http://darwinsource.opendarwin.org/"
SRC_URI="http://darwinsource.opendarwin.org/tarballs/apsl/Csu-${PV}.tar.gz"

LICENSE="APSL-2"

SLOT="0"
KEYWORDS="~ppc-macos"
IUSE=""

DEPEND="sys-devel/odcctools
	|| ( sys-devel/dyld-bin sys-devel/dyld)
	virtual/libc"

S="${WORKDIR}/Csu-${PV}"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${PN}-makefile.patch
}

src_compile() {
	emake \
		CC=$(tc-getCC) \
		INDR="${PREFIX}/usr/bin/indr" \
		NEXT_ROOT=${PREFIX} || die "make failed"
}

src_install() {
	dolib {bundle1.o,crt0.o,crt1.o,dylib1.o,gcrt0.o,gcrt1.o,pscrt0.o,pscrt1.o} \
	|| die "install libs failed"
}
