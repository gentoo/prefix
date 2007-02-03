# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-themes/hicolor-icon-theme/hicolor-icon-theme-0.9-r1.ebuild,v 1.13 2007/01/30 17:40:13 dang Exp $

EAPI="prefix"

# The gnome2 eclass must be inherited to update the icon cache.  All exported
# functions should be overridden

inherit eutils gnome2-utils

DESCRIPTION="Fallback theme for the freedesktop icon theme specification"
HOMEPAGE="http://icon-theme.freedesktop.org/wiki/HicolorTheme"
SRC_URI="http://icon-theme.freedesktop.org/releases/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"
IUSE=""

DEPEND=""
RDEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Add the dropped stock icons
	epatch "${FILESDIR}"/${PN}-0.9-stock-document-icons.patch
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc ChangeLog README
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
