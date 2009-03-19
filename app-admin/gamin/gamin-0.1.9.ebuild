# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/gamin/gamin-0.1.9.ebuild,v 1.16 2009/03/18 14:37:03 ricmm Exp $

EAPI="prefix"

inherit autotools eutils libtool

DESCRIPTION="Library providing the FAM File Alteration Monitor API"
HOMEPAGE="http://www.gnome.org/~veillard/gamin/"
SRC_URI="http://www.gnome.org/~veillard/gamin/sources/${P}.tar.gz"
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="debug kernel_linux"

RDEPEND=">=dev-libs/glib-2
	!app-admin/fam"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

PROVIDE="virtual/fam"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix compile warnings; bug #188923
	epatch "${FILESDIR}"/${P}-compile-warnings.patch
	epatch "${FILESDIR}/${P}-user-cflags.patch"
	epatch "${FILESDIR}/${P}-freebsd.patch"
	epatch "${FILESDIR}/${P}-solaris.patch"
	epatch "${FILESDIR}/${P}-interix.patch"

	# autoconf is required as the user-cflags patch modifies configure.in
	# however, elibtoolize is also required, so when the above patch is
	# removed, replace the following call with a call to elibtoolize
	eautoreconf
}

src_compile() {
	econf --disable-debug \
		$(use_enable kernel_linux inotify) \
		$(use_enable debug debug-api) \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc AUTHORS ChangeLog README TODO NEWS doc/*txt
	dohtml doc/*
}
