# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-base/libxfce4util/libxfce4util-4.6.1.ebuild,v 1.1 2009/04/21 04:24:34 darkside Exp $

EAPI="1"

inherit xfce4

xfce4_core

DESCRIPTION="Basic utilities library"
HOMEPAGE="http://www.xfce.org/projects/libraries"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris"
IUSE="debug doc"

RDEPEND=">=dev-libs/glib-2.12"
DEPEND="${RDEPEND}
	doc? ( dev-util/gtk-doc )"

pkg_setup() {
	XFCE_CONFIG+=" $(use_enable doc gtk_doc)"
}

DOCS="AUTHORS ChangeLog NEWS README README.Kiosk THANKS TODO"
