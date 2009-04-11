# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/icu/icu-3.6-r2.ebuild,v 1.8 2008/12/07 12:06:07 vapier Exp $

inherit eutils

DESCRIPTION="IBM Internationalization Components for Unicode"
HOMEPAGE="http://ibm.com/software/globalization/icu/"
SRC_URI="ftp://ftp.software.ibm.com/software/globalization/icu/${PV}/icu4c-${PV/./_}-src.tgz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="debug"

DEPEND=""
RDEPEND=""

S=${WORKDIR}/${PN}/source

src_unpack() {
	unpack ${A}
	# Bug 208001
	epatch "${FILESDIR}"/${PN}-3.6-regexp-CVE-2007-4770+4771.diff
	cd "${S}"
	epatch "${FILESDIR}"/${P}-darwin.patch
}

src_compile() {
	econf --enable-static $(use_enable debug) || die "econf failed"
	emake -j1 || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dohtml ../readme.html ../license.html
}
