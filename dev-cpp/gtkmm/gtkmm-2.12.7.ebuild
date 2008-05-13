# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/dev-cpp/gtkmm/gtkmm-2.12.7.ebuild,v 1.1 2008/04/11 17:00:29 remi Exp $

EAPI="prefix"

inherit gnome2

DESCRIPTION="C++ interface for GTK+2"
HOMEPAGE="http://gtkmm.sourceforge.net/"

LICENSE="LGPL-2.1"
SLOT="2.4"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="accessibility doc examples"

RDEPEND=">=dev-cpp/glibmm-2.14.1
	>=x11-libs/gtk+-2.12
	>=dev-cpp/cairomm-1.1.12
	>=dev-libs/libsigc++-2.0
	accessibility? ( >=dev-libs/atk-1.9.1 )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

DOCS="AUTHORS CHANGES ChangeLog PORTING NEWS README"

pkg_setup() {
	G2CONF="${G2CONF}
		$(use_enable accessibility api-atkmm)
		$(use_enable doc docs)
		$(use_enable examples)
		$(use_enable examples demos)"
}
