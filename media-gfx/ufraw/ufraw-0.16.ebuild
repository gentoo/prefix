# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/ufraw/ufraw-0.16.ebuild,v 1.10 2009/12/28 22:34:38 maekke Exp $

EAPI=2
inherit fdo-mime gnome2-utils

DESCRIPTION="RAW Image format viewer and GIMP plugin"
HOMEPAGE="http://ufraw.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris"
IUSE="contrast exif lensfun gimp gnome gtk hotpixels openmp timezone"

RDEPEND="media-libs/jpeg
	>=media-libs/lcms-1.13
	media-libs/tiff
	exif? ( >=media-gfx/exiv2-0.11 )
	gnome? ( gnome-base/gconf )
	gtk? ( >=x11-libs/gtk+-2.6:2
		>=media-gfx/gtkimageview-1.5.0 )
	gimp? ( >=x11-libs/gtk+-2.6:2
		>=media-gfx/gtkimageview-1.5.0
		>=media-gfx/gimp-2.0 )
	lensfun? ( >=media-libs/lensfun-0.2.3 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

src_configure() {
	local myconf
	use gimp && myconf="--with-gtk"

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
		$(use_enable timezone dst-correction) \
		${myconf}
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc README TODO || die
}

pkg_postinst() {
	if use gnome; then
		fdo-mime_mime_database_update
		fdo-mime_desktop_database_update
		gnome2_gconf_install
	fi
}

pkg_postrm() {
	if use gnome; then
		fdo-mime_desktop_database_update
		fdo-mime_mime_database_update
	fi
}
