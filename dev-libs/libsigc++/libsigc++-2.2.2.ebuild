# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libsigc++/libsigc++-2.2.2.ebuild,v 1.4 2008/06/23 15:26:32 ranger Exp $

EAPI="prefix"

inherit eutils gnome.org flag-o-matic

DESCRIPTION="Typesafe callback system for standard C++"
HOMEPAGE="http://libsigc.sourceforge.net/"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="debug doc test"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# don't waste time building examples/docs
	sed -i 's|^\(SUBDIRS =.*\)docs examples\(.*\)$|\1\2|' Makefile.in || \
		die "sed docs/examples failed"

	# don't waste time building tests unless USE=test
	if ! use test ; then
		sed -i 's|^\(SUBDIRS =.*\)tests\(.*\)$|\1\2|' Makefile.in || \
			die "sed tests failed"
	fi

	# fix image paths
	if use doc ; then
		sed -i 's|../../images/||g' docs/reference/html/*.html || \
			die "sed failed"
	fi
}

src_compile() {
	filter-flags -fno-exceptions

	local myconf
	use debug \
		&& myconf="--enable-debug=yes" \
		|| myconf="--enable-debug=no"

	econf ${myconf} || die "econf failed."
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed."
	rm -fr "${ED}"/usr/share
	dodoc AUTHORS ChangeLog README NEWS TODO

	if use doc ; then
		dohtml -r docs/reference/html/* docs/images/*
		cp -R examples "${ED}"/usr/share/doc/${PF}/
	fi
}

pkg_postinst() {
	ewarn "To allow parallel installation of sigc++-1.0, sigc++-1.2, and sigc++2.0"
	ewarn "the header files are now installed in a version specific"
	ewarn "subdirectory.  Be sure to unmerge any libsigc++ versions"
	ewarn "< 1.0.4 that you may have previously installed."
}
