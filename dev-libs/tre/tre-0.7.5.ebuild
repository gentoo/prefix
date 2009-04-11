# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/tre/tre-0.7.5.ebuild,v 1.8 2008/02/04 18:36:14 drac Exp $

IUSE="nls"

DESCRIPTION="Lightweight, robust, and efficient POSIX compliant regexp matching library."
HOMEPAGE="http://laurikari.net/tre/index.html"
SRC_URI="http://laurikari.net/tre/${P}.tar.bz2"

SLOT="0"
LICENSE="LGPL-2.1"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"

DEPEND="sys-apps/gawk
		sys-apps/grep
		sys-apps/sed
		sys-devel/gettext
		sys-devel/libtool
		sys-devel/gcc
		dev-util/pkgconfig"
RDEPEND="!app-misc/glimpse
		!app-text/agrep"

src_compile() {
	# --enable-static is required for CRM114. See bug #165378.
	econf \
		$(use_enable nls) \
		--enable-agrep \
		--enable-static \
		--enable-system-abi \
		--disable-profile \
		--disable-debug || die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc NEWS README THANKS TODO AUTHORS
	dohtml doc/*.{html,css}
}

pkg_postinst() {
	ewarn ""
	ewarn "app-misc/glimpse, app-text/agrep and this package all provide agrep."
	ewarn "If this causes any unforeseen incompatibilities please file a bug"
	ewarn "on http://bugs.gentoo.org."
	ewarn ""
}
