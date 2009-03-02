# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/poppler/poppler-0.8.7.ebuild,v 1.9 2008/11/24 20:54:41 ranger Exp $

EAPI="prefix"

inherit libtool eutils flag-o-matic

DESCRIPTION="PDF rendering library based on the xpdf-3.0 code base"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI="http://poppler.freedesktop.org/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="cjk jpeg zlib"

RDEPEND=">=media-libs/freetype-2.1.8
	>=media-libs/fontconfig-2
	cjk? ( app-text/poppler-data )
	jpeg? ( >=media-libs/jpeg-6b )
	dev-libs/libxml2
	!app-text/pdftohtml"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-0.8.3-interix.patch
}

src_compile() {
	[[ ${CHOST} == *-solaris* ]] && append-libs -lrt # for nanosleep

	econf \
		--disable-poppler-qt4 \
		--disable-poppler-glib \
		--disable-poppler-qt \
		--disable-gtk-test \
		--disable-cairo-output \
		--enable-xpdf-headers \
		$(use_enable jpeg libjpeg) \
		$(use_enable zlib) \
		|| die "configuration failed"
	emake || die "compilation failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc README AUTHORS ChangeLog NEWS README-XPDF TODO
}
