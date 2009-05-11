# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/libgnome-python/libgnome-python-2.26.1.ebuild,v 1.1 2009/05/10 21:49:20 eva Exp $

G_PY_PN="gnome-python"
G_PY_BINDINGS="gnome gnomeui"

inherit gnome-python-common

DESCRIPTION="Python bindings for essential GNOME libraries"
LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="examples"

RDEPEND=">=gnome-base/libgnome-2.24.1
	>=gnome-base/libgnomeui-2.24.0
	>=dev-python/pyorbit-2.24.0
	>=dev-python/libbonobo-python-${PV}
	>=dev-python/gnome-vfs-python-${PV}
	>=dev-python/libgnomecanvas-python-${PV}
	!<dev-python/gnome-python-2.22.1"
DEPEND="${RDEPEND}"

EXAMPLES="examples/*
	examples/popt/*"
