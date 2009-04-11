# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/libgnomecanvas-python/libgnomecanvas-python-2.22.3.ebuild,v 1.7 2009/03/23 04:43:14 jer Exp $

G_PY_PN="gnome-python"
G_PY_BINDINGS="gnomecanvas"

inherit gnome-python-common

DESCRIPTION="Python bindings for the Gnome Canvas library"
LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="examples"

RDEPEND=">=gnome-base/libgnomecanvas-2.8
	!<dev-python/gnome-python-2.22.1"
DEPEND="${RDEPEND}"

EXAMPLES="examples/canvas/*"
