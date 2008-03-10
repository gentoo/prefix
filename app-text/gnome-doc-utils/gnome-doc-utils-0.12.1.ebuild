# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/gnome-doc-utils/gnome-doc-utils-0.12.1.ebuild,v 1.3 2008/03/09 22:44:13 leio Exp $

EAPI="prefix"

inherit eutils python gnome2

DESCRIPTION="A collection of documentation utilities for the Gnome project"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~sparc-solaris"
IUSE=""

RDEPEND=">=dev-libs/libxml2-2.6.12
	 >=dev-libs/libxslt-1.1.8
	 >=dev-lang/python-2"
DEPEND="${RDEPEND}
	sys-devel/gettext
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9
	~app-text/docbook-xml-dtd-4.4"

DOCS="AUTHORS ChangeLog NEWS README"

src_unpack() {
	gnome2_src_unpack

	# Fix LINGUAS
	intltoolize --force || die "intltoolize failed"
}

pkg_setup() {
	G2CONF="--disable-scrollkeeper"

	if ! built_with_use dev-libs/libxml2 python; then
		eerror "Please re-emerge dev-libs/libxml2 with the python use flag set"
		die "dev-libs/libxml2 needs python use flag"
	fi
}

pkg_postinst() {
	python_mod_optimize "${EROOT}"usr/share/xml2po
	gnome2_pkg_postinst
}

pkg_postrm() {
	# mod_cleanup adds $ROOT in front for us, while mod_optimize does not
	python_mod_cleanup /usr/share/xml2po
	gnome2_pkg_postrm
}
