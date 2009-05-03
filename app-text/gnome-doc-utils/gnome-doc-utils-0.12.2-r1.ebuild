# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/gnome-doc-utils/gnome-doc-utils-0.12.2-r1.ebuild,v 1.14 2009/05/02 21:04:17 eva Exp $

EAPI=2
inherit autotools eutils python gnome2

DESCRIPTION="A collection of documentation utilities for the Gnome project"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~sparc-solaris"
IUSE=""

RDEPEND=">=dev-libs/libxml2-2.6.12[python]
	 >=dev-libs/libxslt-1.1.8
	 >=dev-lang/python-2"
DEPEND="${RDEPEND}
	dev-libs/glib
	sys-devel/gettext
	>=dev-util/intltool-0.35
	>=dev-util/pkgconfig-0.9
	~app-text/docbook-xml-dtd-4.4"

DOCS="AUTHORS ChangeLog NEWS README"
G2CONF="--disable-scrollkeeper"

src_unpack() {
	gnome2_src_unpack

	# Make xml2po FHS compliant, bug #190798
	epatch "${FILESDIR}/${P}-fhs.patch"

	# Fix LINGUAS
	intltoolize --force || die "intltoolize failed"

	# Beware of first install, bug #224609
	AT_M4DIR="tools" eautomake
}

pkg_postinst() {
	python_version
	python_mod_optimize /usr/lib/python${PYVER}/site-packages/xml2po
	gnome2_pkg_postinst
}

pkg_postrm() {
	python_mod_cleanup /usr/lib/python*/site-packages/xml2po
	gnome2_pkg_postrm
}
