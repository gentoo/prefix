# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/libglade/libglade-2.6.4.ebuild,v 1.7 2009/10/09 18:25:07 armin76 Exp $

EAPI=2

inherit eutils gnome2 autotools flag-o-matic

DESCRIPTION="Library to construct graphical interfaces at runtime"
HOMEPAGE="http://www.gnome.org/"

LICENSE="LGPL-2"
SLOT="2.0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc"

RDEPEND=">=dev-libs/glib-2.10
	>=x11-libs/gtk+-2.8.10
	>=dev-libs/atk-1.9
	>=dev-libs/libxml2-2.4.10
	>=dev-lang/python-2.0-r7"
DEPEND="${RDEPEND}
	>=dev-util/pkgconfig-0.9
	gnome-base/gnome-common
	doc? ( >=dev-util/gtk-doc-1 )"

DOCS="AUTHORS ChangeLog NEWS README"

src_unpack() {
	gnome2_src_unpack

	AT_M4DIR=m4 eautoreconf # need new libtool for interix
	
	# Needed for solaris, else gcc finds a syntax error in /usr/include/signal.h
	[[ ${CHOST} == *-solaris* ]] && append-flags "-D__EXTENSIONS__"
}

src_prepare() {
	# patch to stop make install installing the xml catalog
	# because we do it ourselves in postinst()
	epatch "${FILESDIR}"/Makefile.in.am-2.4.2-xmlcatalog.patch

	# patch to not throw a warning with gtk+-2.14 during tests, as it triggers abort
	epatch "${FILESDIR}/${PN}-2.6.3-fix_tests-page_size.patch"
}

src_install() {
	dodir /etc/xml
	gnome2_src_install
}

pkg_postinst() {
	echo ">>> Updating XML catalog"
	"${EPREFIX}"/usr/bin/xmlcatalog --noout --add "system" \
		"http://glade.gnome.org/glade-2.0.dtd" \
		"${EPREFIX}"/usr/share/xml/libglade/glade-2.0.dtd "${EPREFIX}"/etc/xml/catalog
	gnome2_pkg_postinst
}

pkg_postrm() {
	gnome2_pkg_postrm
	echo ">>> removing entries from the XML catalog"
	"${EPREFIX}"/usr/bin/xmlcatalog --noout --del \
		"${EPREFIX}"/usr/share/xml/libglade/glade-2.0.dtd "${EPREFIX}"/etc/xml/catalog
}
