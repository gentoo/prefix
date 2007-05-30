# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/zoo/zoo-2.10-r3.ebuild,v 1.4 2007/05/24 15:30:56 corsair Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Manipulate archives of files in compressed form."
HOMEPAGE="ftp://ftp.kiarchive.ru/pub/unix/arcers"
SRC_URI="ftp://ftp.kiarchive.ru/pub/unix/arcers/${P}pl1.tar.gz
	mirror://gentoo/${P}-gcc-issues-fix.patch"

LICENSE="zoo"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

S=${WORKDIR}

src_unpack() {
	unpack ${P}pl1.tar.gz
	epatch "${DISTDIR}"/${P}-gcc-issues-fix.patch
	epatch "${FILESDIR}"/${P}-CAN-2005-2349.patch
	epatch "${FILESDIR}"/${P}-febz-183426.patch
	epatch "${FILESDIR}"/${P}-security_pathsize.patch
	epatch "${FILESDIR}"/${P}-multiple-dos-fix.patch
}

src_compile() {
	emake linux || die
}

src_install() {
	dobin zoo fiz || die
	doman zoo.1 fiz.1
}
