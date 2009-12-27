# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/ufraw/ufraw-0.16.ebuild,v 1.7 2009/12/23 17:41:28 hwoarang Exp $

inherit fdo-mime gnome2-utils

DESCRIPTION="RAW Image format viewer and GIMP plugin"
HOMEPAGE="http://ufraw.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris"
IUSE="contrast exif lensfun gimp gnome gtk hotpixels openmp timezone"

RDEPEND="
	media-libs/jpeg
	>=media-libs/lcms-1.13
	media-libs/tiff
	>=x11-libs/gtk+-2.4.0
	exif? ( >=media-gfx/exiv2-0.11 )
	gnome? ( gnome-base/gconf )
	gtk? ( >=x11-libs/gtk+-2.6.0
		>=media-gfx/gtkimageview-1.5.0
		gimp? ( >=media-gfx/gimp-2.0 ) )
	lensfun? ( >=media-libs/lensfun-0.2.3 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

pkg_setup() {
	if use gimp && ! use gtk; then
		eerror "to enable gimp support, you must enable gtk support"
		die "emerge ${PN} with gtk support"
	fi
}

src_compile() {
	econf \
		--without-cinepaint \
		$(use_enable contrast) \
		$(use_with exif exiv2) \
		$(use_with gimp) \
		$(use_enable gnome mime) \
		$(use_with gtk) \
		$(use_enable hotpixels) \
		$(use_with lensfun) \
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
