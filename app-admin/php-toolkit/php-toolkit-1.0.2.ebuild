# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/php-toolkit/php-toolkit-1.0.2.ebuild,v 1.1 2009/12/30 00:47:19 hoffie Exp $
EAPI="2"

inherit multilib eutils prefix

DESCRIPTION="Utilities for managing installed copies of PHP"
HOMEPAGE="http://www.gentoo.org/proj/en/php/"
SRC_URI="http://dev.gentoo.org/~hoffie/distfiles/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=""

src_prepare() {
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify php-select php-select-modules/*
}

src_configure() {
	sed -i php-select -e "s:@@GENTOO_LIBDIR@@:$(get_libdir):" || \
		die "GENTOO_LIBDIR sed failed"
}

src_install() {
	# install php-select
	dosbin php-select || die

	dodir /usr/share/php-select
	insinto /usr/share/php-select
	doins php-select-modules/*

	dodoc ChangeLog TODO
}
