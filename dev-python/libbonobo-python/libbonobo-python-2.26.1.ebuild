# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/libbonobo-python/libbonobo-python-2.26.1.ebuild,v 1.1 2009/05/10 21:48:48 eva Exp $

G_PY_PN="gnome-python"
G_PY_BINDINGS="bonobo bonoboui bonobo_activation"

inherit gnome-python-common

DESCRIPTION="Python bindings for the Bonobo framework"
LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="examples"

RDEPEND=">=dev-python/pyorbit-2.24.0
	>=gnome-base/libbonobo-2.24.0
	>=gnome-base/libbonoboui-2.24.0
	>=dev-python/libgnomecanvas-python-${PV}
	!<dev-python/gnome-python-2.22.1"
DEPEND="${RDEPEND}"

EXAMPLES="examples/bonobo/*
	examples/bonobo/bonoboui/
	examples/bonobo/echo/"
