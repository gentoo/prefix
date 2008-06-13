# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/emacs-desktop/emacs-desktop-0.2-r1.ebuild,v 1.11 2008/01/10 09:33:48 vapier Exp $

EAPI="prefix"

inherit eutils fdo-mime gnome2-utils

DESCRIPTION="Desktop entry and icon for Emacs"
HOMEPAGE="http://www.gentoo.org/proj/en/lisp/emacs/"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris"
IUSE=""

src_install() {
	local i
	domenu emacs.desktop emacsclient.desktop
	newicon emacs_48.png emacs.png
	for i in 16 24 32 48; do
		insinto /usr/share/icons/hicolor/${i}x${i}/apps
		newins emacs_${i}.png emacs.png
	done
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
