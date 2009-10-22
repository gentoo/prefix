# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-libs/libgeotiff/libgeotiff-1.3.0_beta1.ebuild,v 1.2 2009/10/18 06:13:14 nerdboy Exp $

EAPI="2"
inherit eutils flag-o-matic

MY_P=${P/_beta/b}
MY_S=${P/_beta1/}

DESCRIPTION="Library for reading TIFF files with embedded tags for geographic (cartographic) information"
HOMEPAGE="http://geotiff.osgeo.org/"
SRC_URI="ftp://ftp.remotesensing.org/pub/geotiff/${PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="debug doc"

RDEPEND=">=media-libs/tiff-3.9.1
	media-libs/jpeg
	sci-libs/proj"

DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

S=${WORKDIR}/${MY_S}

src_configure() {
	local my_conf=""

	if use debug; then
		my_conf="--enable-debug=yes"
	else
		my_conf="--enable-debug=no"
	fi

	econf || die "econf failed"
}
src_compile() {
	emake || die "emake failed"

	if use doc; then
		mkdir -p docs/api
		cp "${FILESDIR}"/Doxyfile Doxyfile
		doxygen -u Doxyfile || die "updating doxygen config failed"
		doxygen Doxyfile || die "docs generation failed"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc README
	use doc && dohtml docs/api/*
}

pkg_postinst() {
	elog
	ewarn "You should rebuild any packages built against ${PN}"
	ewarn "by running: revdep-rebuild --library='libgeotiff.so.*'"
	elog
}
