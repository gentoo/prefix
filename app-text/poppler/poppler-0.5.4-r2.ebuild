# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/poppler/poppler-0.5.4-r2.ebuild,v 1.10 2007/08/29 10:16:04 corsair Exp $

EAPI="prefix"

inherit libtool eutils

DESCRIPTION="PDF rendering library based on the xpdf-3.0 code base"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI="http://poppler.freedesktop.org/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris"
IUSE="cjk jpeg zlib"

RDEPEND=">=media-libs/freetype-2.1.8
	media-libs/fontconfig
	cjk? ( app-text/poppler-data )
	jpeg? ( >=media-libs/jpeg-6b )
	!app-text/pdftohtml"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch ${FILESDIR}/004_CVE-2007-0104.patch
	epatch ${FILESDIR}/poppler-cve-2007-3387.patch
	elibtoolize
}

src_compile() {
	econf \
		--disable-poppler-qt4 \
		--disable-poppler-glib \
		--disable-poppler-qt \
		--disable-gtk-test \
		--enable-opi \
		--disable-cairo-output \
		--enable-xpdf-headers \
		$(use_enable jpeg libjpeg) \
		$(use_enable zlib) \
		|| die "configuration failed"
	emake || die "compilation failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc README AUTHORS ChangeLog NEWS README-XPDF TODO pdf2xml.dtd
}
