# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/gnome-doc-utils/gnome-doc-utils-0.10.3.ebuild,v 1.1 2007/04/17 02:37:36 compnerd Exp $

EAPI="prefix"

inherit python eutils gnome2

DESCRIPTION="A collection of documentation utilities for the Gnome project"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86"
IUSE=""

RDEPEND=">=dev-libs/libxml2-2.6.12
	 >=dev-libs/libxslt-1.1.8
	 >=dev-lang/python-2"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/intltool-0.28
	>=dev-util/pkgconfig-0.9
	~app-text/docbook-xml-dtd-4.4"

DOCS="AUTHORS ChangeLog NEWS README"

pkg_setup() {
	G2CONF="--disable-scrollkeeper"

	if ! built_with_use dev-libs/libxml2 python; then
		eerror "Please re-emerge dev-libs/libxml2 with the python use flag set"
		die "dev-libs/libxml2 needs python use flag"
	fi
}

pkg_postinst() {
	python_mod_optimize ${EROOT}usr/share/xml2po
	gnome2_pkg_postinst
}

pkg_postrm() {
	python_mod_cleanup ${EROOT}usr/share/xml2po
	gnome2_pkg_postrm
}
