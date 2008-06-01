# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/gamin/gamin-0.1.9.ebuild,v 1.15 2007/11/06 21:57:25 leio Exp $

EAPI="prefix"

inherit autotools eutils libtool flag-o-matic

DESCRIPTION="Library providing the FAM File Alteration Monitor API"
HOMEPAGE="http://www.gnome.org/~veillard/gamin/"
SRC_URI="http://www.gnome.org/~veillard/gamin/sources/${P}.tar.gz"
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
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
	[[ ${CHOST} == *-interix* ]] && {
		append-flags -D_ALL_SOURCE
	}

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
