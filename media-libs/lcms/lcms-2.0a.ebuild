# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/lcms/lcms-2.0a.ebuild,v 1.7 2010/07/23 20:40:22 ssuominen Exp $

EAPI=2
inherit libtool

DESCRIPTION="A lightweight, speed optimized color management engine"
HOMEPAGE="http://www.littlecms.com/"
SRC_URI="mirror://sourceforge/${PN}/lcms2-${PV}.tar.gz"

LICENSE="MIT"
SLOT="2"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="jpeg static-libs tiff zlib"

DEPEND="jpeg? ( virtual/jpeg )
	tiff? ( media-libs/tiff )
	jpeg? ( virtual/jpeg )
	zlib? ( sys-libs/zlib )"

RESTRICT="test" # Segment maxima GBD test fails with gcc-4.4, but not with gcc-4.5

S=${WORKDIR}/${P/a}

src_prepare() {
	elibtoolize
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		$(use_enable static-libs static) \
		$(use_with jpeg) \
		$(use_with tiff) \
		$(use_with zlib)
}

src_install() {
	emake DESTDIR="${D}" install || die

	insinto /usr/share/lcms2/profiles
	doins testbed/*.icm || die

	dodoc AUTHORS ChangeLog || die

	insinto /usr/share/doc/${PF}/pdf
	doins doc/*.pdf || die

	find "${ED}" -name '*.la' -delete
}
