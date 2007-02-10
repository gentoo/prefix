# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/dev-db/unixODBC/unixODBC-2.2.11-r1.ebuild,v 1.18 2007/01/04 14:36:47 flameeyes Exp $

EAPI="prefix"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit eutils multilib autotools

KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"

DESCRIPTION="ODBC Interface for Linux."
HOMEPAGE="http://www.unixodbc.org/"
SRC_URI="http://www.unixodbc.org/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
IUSE="qt3"

DEPEND=">=sys-libs/readline-4.1
		>=sys-libs/ncurses-5.2
		qt3? ( =x11-libs/qt-3* )"
RDEPEND="${DEPEND}"

# the configure.in patch is required for 'use qt3'
src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}"

	# solve bug #110167
	epatch "${FILESDIR}/${P}-flex.patch"
	# braindead check in configure fails - hackish approach
	epatch "${FILESDIR}/${P}-configure.in.patch"
	epatch "${FILESDIR}/${P}-Makefile.am.patch"

	eautoreconf
}

src_compile() {
	local myconf

	if use qt3 && ! use mips ; then
		myconf="--enable-gui=yes --x-libraries=/usr/$(get_libdir)"
	else
		myconf="--enable-gui=no"
	fi

	econf --prefix=${EPREFIX}/usr \
		--sysconfdir=${EPREFIX}/etc/${PN} \
		--libdir=${EPREFIX}/usr/$(get_libdir) \
		${myconf} || die "econf failed"

	emake -j1 || die "emake failed"
}

src_install() {
	emake -j1 DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog NEWS README*
	find doc/ -name "Makefile*" -exec rm '{}' \;
	dohtml doc/*
	prepalldocs
}
