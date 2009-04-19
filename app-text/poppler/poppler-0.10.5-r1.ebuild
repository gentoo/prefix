# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/poppler/poppler-0.10.5-r1.ebuild,v 1.4 2009/04/18 12:42:16 ranger Exp $

EAPI=2

inherit libtool eutils flag-o-matic

DESCRIPTION="PDF rendering library based on the xpdf-3.0 code base"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI="http://poppler.freedesktop.org/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc"

RDEPEND="
	>=media-libs/freetype-2.1.8
	>=media-libs/fontconfig-2
	app-text/poppler-data
	>=media-libs/jpeg-6b
	media-libs/openjpeg
	sys-libs/zlib
	dev-libs/libxml2
	!app-text/pdftohtml
	!dev-libs/poppler-qt3
	!dev-libs/poppler-qt4
	!dev-libs/poppler
	!dev-libs/poppler-glib
	!app-text/poppler-utils
	"
DEPEND="
	${RDEPEND}
	dev-util/pkgconfig
	doc? ( >=dev-util/gtk-doc-1.0 )
	"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-0.8.3-interix.patch
}

src_prepare () {
	epatch "${FILESDIR}/poppler-0.10.5-xpdf-3.02pl3.patch"
	epatch "${FILESDIR}/poppler-CVE-2009-1188.patch"
}

src_configure() {
	[[ ${CHOST} == *-solaris* ]] && append-libs -lrt # for nanosleep

	econf 	--disable-static		\
		--disable-poppler-qt4		\
		--disable-poppler-glib		\
		--disable-poppler-qt		\
		--disable-gtk-test		\
		--disable-cairo-output		\
		--enable-xpdf-headers		\
		--enable-libjpeg		\
		--enable-libopenjpeg		\
		--enable-zlib			\
		$(use_enable doc gtk-doc)	\
		|| die "configuration failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc README AUTHORS ChangeLog NEWS README-XPDF TODO
	rm -f $(find "${ED}" -name '*.la')
}
