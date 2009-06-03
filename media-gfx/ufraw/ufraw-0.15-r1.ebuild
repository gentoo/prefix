# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/ufraw/ufraw-0.15-r1.ebuild,v 1.9 2009/06/01 13:37:56 maekke Exp $

inherit fdo-mime gnome2-utils autotools

DESCRIPTION="RAW Image format viewer and GIMP plugin"
HOMEPAGE="http://ufraw.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris"
IUSE="contrast exif gimp gnome openmp timezone"

RDEPEND="media-libs/jpeg
	>=media-libs/lcms-1.13
	media-libs/tiff
	>=x11-libs/gtk+-2.4.0
	exif? ( >=media-libs/libexif-0.6.13
	        media-gfx/exiv2 )
	gimp? ( >=media-gfx/gimp-2.0 )
	gnome? ( gnome-base/gconf )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-configure.patch
	epatch "${FILESDIR}"/${P}-glibc-2.10.patch
	epatch "${FILESDIR}"/${PN}-0.14.1-solaris-ctime_r.patch
	eautoreconf
}

src_compile() {
	econf \
		--without-cinepaint \
		--without-gtkimageview \
		--without-lensfun \
		$(use_enable contrast) \
		$(use_with exif exiv2) \
		$(use_with gimp) \
		$(use_enable gnome mime) \
		$(use_enable openmp) \
		$(use_enable timezone dst-correction)
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc README TODO || die "doc installation failed"
}

pkg_postinst() {
	if use gnome ; then
		fdo-mime_mime_database_update
		gnome2_gconf_install
		fdo-mime_desktop_database_update
	fi
}
