# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-gfx/ufraw/ufraw-0.14.1.ebuild,v 1.12 2009/01/01 15:00:51 armin76 Exp $

inherit eutils autotools fdo-mime gnome2-utils

DESCRIPTION="RAW Image format viewer and GIMP plugin"
HOMEPAGE="http://ufraw.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="contrast exif gimp gnome timezone"

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
	epatch "${FILESDIR}"/${PN}-0.13-cflags.patch
	epatch "${FILESDIR}"/${PN}-0.14.1-solaris-ctime_r.patch
	eautoreconf || die "failed running autoreconf"
}

src_compile() {
	econf \
		$(use_enable contrast) \
		$(use_enable gnome mime) \
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
