# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/icu/icu-3.6.ebuild,v 1.10 2007/04/21 12:16:11 armin76 Exp $

EAPI="prefix"

DESCRIPTION="IBM Internationalization Components for Unicode"
HOMEPAGE="http://ibm.com/software/globalization/icu/"
SRC_URI="ftp://ftp.software.ibm.com/software/globalization/icu/${PV}/icu4c-${PV/./_}-src.tgz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~x86"
IUSE=""

DEPEND=""
RDEPEND=""

S=${WORKDIR}/${PN}/source

src_compile() {
	econf || die "econf failed"
	emake -j1 || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dohtml ../readme.html ../license.html
}
