# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/jbigkit/jbigkit-1.6-r1.ebuild,v 1.18 2007/02/28 22:13:22 genstef Exp $

EAPI="prefix"

inherit eutils multilib toolchain-funcs

DESCRIPTION="highly effective data compression algorithm for bi-level high-resolution images such as fax pages or scanned documents"
HOMEPAGE="http://www.cl.cam.ac.uk/~mgk25/jbigkit/"
SRC_URI="http://www.cl.cam.ac.uk/~mgk25/download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

DEPEND=">=sys-apps/sed-4"
RDEPEND=""

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-build.patch
	epatch "${FILESDIR}"/${P}-shared-lib.patch
	epatch "${FILESDIR}"/${P}-respect-make.patch
}

src_compile() {
	emake CC=$(tc-getCC) || die "emake failed"
}

src_test() {
	LD_LIBRARY_PATH="${S}"/libjbig make test || die "make test failed"
}

src_install() {
	dobin pbmtools/jbgtopbm pbmtools/pbmtojbg || die "dobin"
	doman pbmtools/jbgtopbm.1 pbmtools/pbmtojbg.1

	insinto /usr/include
	newins libjbig/jbig.h jbig.h || die "doins include"
	dolib libjbig/libjbig{.a,$(get_libname)} || die "dolib"

	dodoc ANNOUNCE CHANGES INSTALL TODO
}
