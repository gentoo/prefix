# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/glibmm/glibmm-2.16.4.ebuild,v 1.8 2009/01/07 17:56:58 armin76 Exp $

inherit gnome2

DESCRIPTION="C++ interface for glib2"
HOMEPAGE="http://www.gtkmm.org"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="doc examples"

RDEPEND=">=dev-libs/libsigc++-2.2
		 >=dev-libs/glib-2.16"
DEPEND="${RDEPEND}
		dev-util/pkgconfig
		doc? ( app-doc/doxygen )"

DOCS="AUTHORS ChangeLog NEWS README"

src_unpack() {
	gnome2_src_unpack

	# don't waste time building tests
	# no USE=test because there is no "check" target
	sed -i 's/^\(SUBDIRS =.*\)tests\(.*\)$/\1\2/' Makefile.in || die "sed failed"

	if ! use examples; then
		# don't waste time building examples
		sed -i 's/^\(SUBDIRS =.*\)examples\(.*\)$/\1\2/' Makefile.in || die "sed failed"
	fi
}

src_install() {
	gnome2_src_install

	if ! use doc && ! use examples; then
		rm -fr "${ED}/usr/share/doc/glibmm-2.4"
	fi

	if use examples; then
		find examples -type d -name '.deps' -exec rm -rf {} \; 2>/dev/null
		dodoc examples
	fi
}
