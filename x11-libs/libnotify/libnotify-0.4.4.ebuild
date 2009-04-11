# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libnotify/libnotify-0.4.4.ebuild,v 1.14 2009/01/19 19:18:38 pva Exp $

inherit eutils

DESCRIPTION="Notifications library"
HOMEPAGE="http://www.galago-project.org/"
SRC_URI="http://www.galago-project.org/files/releases/source/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="doc"

RDEPEND=">=x11-libs/gtk+-2.6
		>=dev-libs/glib-2.6
		>=dev-libs/dbus-glib-0.71"
DEPEND="${RDEPEND}
		doc? ( >=dev-util/gtk-doc-1.4 )"
PDEPEND="|| ( x11-misc/notification-daemon
			x11-misc/notification-daemon-xfce )"

src_install() {
	emake install DESTDIR="${D}" || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS
}
