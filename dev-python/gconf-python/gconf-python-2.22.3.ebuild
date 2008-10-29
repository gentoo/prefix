# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/gconf-python/gconf-python-2.22.3.ebuild,v 1.2 2008/10/27 01:18:18 hawking Exp $

EAPI="prefix"

G_PY_PN="gnome-python"

inherit gnome-python-common python

DESCRIPTION="Python bindings for the GConf library"
LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="examples"

RDEPEND=">=gnome-base/gconf-2.11.1
	!<dev-python/gnome-python-2.22.1"
DEPEND="${RDEPEND}"

EXAMPLES="examples/gconf/*"

src_install() {
	python_need_rebuild
	gnome-python-common_src_install
}
