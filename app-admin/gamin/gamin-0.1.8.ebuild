# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/gamin/gamin-0.1.8.ebuild,v 1.11 2007/05/23 20:46:05 armin76 Exp $

EAPI="prefix"

inherit autotools eutils libtool

DESCRIPTION="Library providing the FAM File Alteration Monitor API"
HOMEPAGE="http://www.gnome.org/~veillard/gamin/"
SRC_URI="http://www.gnome.org/~veillard/gamin/sources/${P}.tar.gz
	kernel_FreeBSD? ( mirror://gentoo/${PN}-0.1.7-freebsd.patch.bz2 )"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86"
IUSE="debug kernel_FreeBSD kernel_linux"

RDEPEND=">=dev-libs/glib-2
	!app-admin/fam"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

PROVIDE="virtual/fam"

src_unpack() {
	unpack ${A}

	cd ${S}
	use kernel_FreeBSD && epatch "${DISTDIR}/${PN}-0.1.7-freebsd.patch.bz2"

	# Do not remove
	elibtoolize
}

src_compile() {
	econf \
		$(use_enable kernel_linux inotify) \
		$(use_enable debug) \
		$(use_enable debug debug-api) \
		|| die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die

	dodoc AUTHORS ChangeLog README TODO NEWS doc/*txt
	dohtml doc/*
}

