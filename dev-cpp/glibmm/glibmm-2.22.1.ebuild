# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/glibmm/glibmm-2.22.1.ebuild,v 1.4 2010/03/06 16:17:37 phajdan.jr Exp $

inherit gnome2

DESCRIPTION="C++ interface for glib2"
HOMEPAGE="http://www.gtkmm.org"

LICENSE="|| ( LGPL-2.1 GPL-2 )"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="doc examples test"

RDEPEND=">=dev-libs/libsigc++-2.2
	>=dev-libs/glib-2.21.1"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( app-doc/doxygen )"

DOCS="AUTHORS ChangeLog NEWS README"

src_unpack() {
	gnome2_src_unpack

	if ! use test; then
		# don't waste time building tests
		sed 's/^\(SUBDIRS =.*\)tests\(.*\)$/\1\2/' \
			-i Makefile.am Makefile.in || die "sed 1 failed"
	fi

	if ! use examples; then
		# don't waste time building examples
		sed 's/^\(SUBDIRS =.*\)examples\(.*\)$/\1\2/' \
			-i Makefile.am Makefile.in || die "sed 2 failed"
	fi
}

src_test() {
	cd "${S}/tests/"
	emake check || die "emake check failed"

	# Workaround bug 295726 until upstream fixes it
	# for i in */test; do
	export  \
	LD_LIBRARY_PATH="${S}/glib/glibmm/.libs:${S}/gio/giomm/.libs:${LD_LIBRARY_PATH}"
	for i in */.libs/test; do
		${i} || die "Running tests failed at ${i}"
	done
}

src_install() {
	gnome2_src_install

	if ! use doc && ! use examples; then
		rm -fr "${ED}/usr/share/doc/glibmm*"
	fi

	if use examples; then
		find examples -type d -name '.deps' -exec rm -rf {} \; 2>/dev/null
		dodoc examples
	fi
}
