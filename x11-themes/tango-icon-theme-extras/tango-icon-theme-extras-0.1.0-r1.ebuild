# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/tango-icon-theme-extras/tango-icon-theme-extras-0.1.0-r1.ebuild,v 1.11 2008/06/29 07:41:08 tove Exp $

inherit eutils gnome2-utils

DESCRIPTION="This is an extension to the Tango Icon Theme. It includes Tango icons for iPod Digital Audio Player (DAP) devices and the Dell Pocket DJ DAP."
HOMEPAGE="http://tango.freedesktop.org"
SRC_URI="http://tango.freedesktop.org/releases/${P}.tar.gz"

LICENSE="CCPL-Attribution-ShareAlike-2.5"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="png"

RESTRICT="binchecks strip"

RDEPEND=">=x11-misc/icon-naming-utils-0.6.0
	media-gfx/imagemagick
	>=gnome-base/librsvg-2.12.3
	>=x11-themes/tango-icon-theme-0.8"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

pkg_setup() {
	if use png && ! built_with_use media-gfx/imagemagick png; then
		die "Build media-gfx/imagemagick with USE=png."
	fi
}

src_compile() {
	econf $(use_enable png png-creation) \
		$(use_enable png icon-framing)
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
