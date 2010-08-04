# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/mksh/mksh-39c.ebuild,v 1.2 2010/07/11 12:02:59 patrick Exp $

inherit eutils prefix

DESCRIPTION="MirBSD KSH Shell"
HOMEPAGE="http://mirbsd.de/mksh"
ARC4_VERSION="1.14"
SRC_URI="http://www.mirbsd.org/MirOS/dist/mir/mksh/${PN}-R${PV}.cpio.gz
	http://www.mirbsd.org/MirOS/dist/hosted/other/arc4random.c.${ARC4_VERSION}"
LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""
DEPEND="app-arch/cpio"
RDEPEND=""
S="${WORKDIR}/${PN}"

src_unpack() {
	gzip -dc "${DISTDIR}/${PN}-R${PV}.cpio.gz" | cpio -mid
	cp "${DISTDIR}/arc4random.c.${ARC4_VERSION}" "${S}/arc4random.c" || die
	epatch "${FILESDIR}/${P}-urandom-write.patch"

	cd "${S}"
	epatch "${FILESDIR}"/${PN}-33d-prefix.patch
	eprefixify sh.h
}

src_compile() {
	tc-export CC
	sh Build.sh -r || die
}

src_install() {
	exeinto /bin
	doexe mksh || die
	doman mksh.1 || die
	dodoc dot.mkshrc || die
}

src_test() {
	./test.sh || die
}
