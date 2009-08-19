# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/gtksourceview-python/gtksourceview-python-2.26.0.ebuild,v 1.1 2009/05/10 21:41:55 eva Exp $

G_PY_PN="gnome-python-desktop"

inherit gnome-python-common

DESCRIPTION="Python bindings for the gtksourceview (version 1.8) library"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="doc examples"

RDEPEND="=x11-libs/gtksourceview-1.8*
	>=dev-python/libgnomeprint-python-2.25.90
	!<dev-python/gnome-python-desktop-2.22.0-r10"
DEPEND="${RDEPEND}"

EXAMPLES="examples/gtksourceview/*"

pkg_postinst() {
	elog
	elog "This package provides python bindings for x11-libs/gtksourceview-1.8."
	elog "If you want to 2.* python bindings, use dev-python/pygtksourceview-2"
}
