# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libfpx/libfpx-1.3.0.ebuild,v 1.2 2009/08/28 09:21:19 ssuominen Exp $

EAPI=2
inherit libtool

DESCRIPTION="A library for manipulating FlashPIX images"
HOMEPAGE="http://www.i3a.org/"
SRC_URI="ftp://ftp.imagemagick.org/pub/ImageMagick/delegates/${P}-1.tar.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE=""

src_prepare() {
	elibtoolize
}

src_configure() {
	econf \
		--disable-dependency-tracking
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog doc/*.txt || die "dodoc failed"
	insinto /usr/share/doc/${PF}/pdf
	doins doc/*.pdf || die "doins failed"
}
