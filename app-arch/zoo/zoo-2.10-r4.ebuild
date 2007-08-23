# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/zoo/zoo-2.10-r4.ebuild,v 1.2 2007/08/22 14:00:08 uberlord Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Manipulate archives of files in compressed form."
HOMEPAGE="ftp://ftp.kiarchive.ru/pub/unix/arcers"
SRC_URI="ftp://ftp.kiarchive.ru/pub/unix/arcers/${P}pl1.tar.gz
	mirror://gentoo/${P}-gcc-issues-fix.patch"

LICENSE="zoo"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~x86-solaris"
IUSE=""

S=${WORKDIR}

src_unpack() {
	unpack ${A}
	epatch "${DISTDIR}"/${P}-gcc-issues-fix.patch
	epatch "${FILESDIR}"/${P}-CAN-2005-2349.patch
	epatch "${FILESDIR}"/${P}-febz-183426.patch
	epatch "${FILESDIR}"/${P}-security_pathsize.patch
	epatch "${FILESDIR}"/${P}-multiple-dos-fix.patch
	epatch "${FILESDIR}"/${P}-gentoo-fbsd.patch
}

src_compile() {
	# emake no workie on FreeBSD
	make CC="$(tc-getCC)" linux || die
}

src_install() {
	dobin zoo fiz || die
	doman zoo.1 fiz.1
}
