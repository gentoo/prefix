# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/gam-server/gam-server-0.1.10.ebuild,v 1.8 2009/04/28 18:15:34 armin76 Exp $

inherit autotools eutils flag-o-matic libtool python

MY_PN="gamin"
MY_P=${MY_PN}-${PV}

DESCRIPTION="Library providing the FAM File Alteration Monitor API"
HOMEPAGE="http://www.gnome.org/~veillard/gamin/"
SRC_URI="http://www.gnome.org/~veillard/${MY_PN}/sources/${MY_P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="debug kernel_linux"

RDEPEND=">=dev-libs/glib-2
	>=dev-libs/libgamin-0.1.10
	!app-admin/fam
	!<app-admin/gamin-0.1.10"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix compile warnings; bug #188923
	[[ ${CHOST} != *-solaris* ]] && \
	epatch "${FILESDIR}/${MY_PN}-0.1.9-freebsd.patch"

	# Fix file-collision due to shared library, upstream bug #530635
	epatch "${FILESDIR}/${P}-noinst-lib.patch"

	# (Open)Solaris necessary patches (changes configure.in), unfortunately
	# conflicts with freebsd patch and messes up Linux
	[[ ${CHOST} == *-solaris* ]] && \
	epatch "${FILESDIR}"/libgamin-0.1.10-opensolaris.patch

	# autoconf is required as the user-cflags patch modifies configure.in
	# however, elibtoolize is also required, so when the above patch is
	# removed, replace the following call with a call to elibtoolize
	eautoreconf
}

src_compile() {
	# fixes bug 225403
	#append-flags "-D_GNU_SOURCE"

	econf --disable-debug \
		--disable-libgamin \
		$(use_enable kernel_linux inotify) \
		$(use_enable debug debug-api)

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "installation failed"
}
