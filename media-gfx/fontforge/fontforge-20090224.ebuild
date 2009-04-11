# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/fontforge/fontforge-20090224.ebuild,v 1.1 2009/02/25 21:43:42 vapier Exp $

# Some notes for maintainers this package:
# 1. README-unix: freetype headers are required to make use of truetype debugger
# in fontforge.
# 2. --enable-{double,longdouble} these just make ff use more storage space. In
# normal fonts neither is useful. Leave off.
# 3. FontForge autodetects libraries but does not link with them. They are
# dynamically loaded at run time if fontforge found them at build time.
# --with-regular-link disables this behaviour. No reason to make it optional for
# users. http://fontforge.sourceforge.net/faq.html#libraries. To see what
# libraries fontforge thinks with use $ fontforge --library-status

EAPI=2
inherit eutils fdo-mime

CIDMAPV="20090121"
DESCRIPTION="postscript font editor and converter"
HOMEPAGE="http://fontforge.sourceforge.net/"
SRC_URI="mirror://sourceforge/fontforge/${PN}_full-${PV}.tar.bz2
	doc? ( mirror://sourceforge/fontforge/fontforge_htdocs-${PV}.tar.bz2 )
	cjk? ( mirror://gentoo/cidmaps-${CIDMAPV}.tgz )"	# http://fontforge.sf.net/cidmaps.tgz

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="cjk doc gif debug jpeg nls pasteafter png +python tiff tilepath truetype truetype-debugger type3 svg unicode +X"

RDEPEND="gif? ( >=media-libs/giflib-4.1.0-r1 )
	jpeg? ( >=media-libs/jpeg-6b-r2 )
	png? ( >=media-libs/libpng-1.2.4 )
	python? ( dev-lang/python )
	tiff? ( >=media-libs/tiff-3.5.7-r1 )
	truetype? ( >=media-libs/freetype-2.1.4 )
	truetype-debugger? ( >=media-libs/freetype-2.3.8[fontforge,-bindist] )
	svg? ( >=dev-libs/libxml2-2.6.7 )
	unicode? ( >=media-libs/libuninameslist-030713 )
	x11-libs/libXi
	x11-proto/inputproto
	!media-gfx/pfaedit"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${PN}_full-${PV}.tar.bz2
	use cjk && unpack cidmaps-${CIDMAPV}.tgz
	if use doc; then
		mkdir html
		cd html
		unpack fontforge_htdocs-${PV}.tar.bz2
	fi
	cd "${S}"
	epatch "${FILESDIR}/fontforge-desktop.patch"
}

src_prepare() {
	if use doc; then
		cd "${WORKDIR}/html/"
		chmod -x *.html
	fi
}

src_configure() {
	# no real way of disabling gettext/nls ...
	use nls || export ac_cv_header_libintl_h=no
	econf \
		$(use_with truetype-debugger freetype-src "/usr/include/freetype2/internal4fontforge/") \
		$(use_enable type3) \
		$(use_with python) \
		$(use_with python pyextension) \
		$(use_enable pasteafter) \
		$(use_with X x) \
		$(use_enable cjk gb12345) \
		$(use_enable tilepath) \
		$(use_enable debug debug-raw-points)
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS README*

	if use cjk; then #129518
		insinto /usr/share/fontforge
		doins "${WORKDIR}"/*.cidmap
	fi

	doicon Packaging/fontforge.png
	insinto /usr/share/applications
	doins Packaging/fontforge.desktop
	insinto /usr/share/mime/application
	doins Packaging/fontforge.xml

	if use doc; then
		insinto /usr/share/doc/${PN}
		cd "${WORKDIR}/html/"
		doins -r *
	fi
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	fdo-mime_mime_database_update
}
