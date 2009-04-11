# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/php-toolkit/php-toolkit-1.0.1.ebuild,v 1.8 2008/04/14 01:31:52 vapier Exp $

inherit eutils prefix

DESCRIPTION="Utilities for managing installed copies of PHP"
HOMEPAGE="http://www.gentoo.org/proj/en/php/"
SRC_URI="http://gentoo.longitekk.com/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify php-select php-select-modules/*
}

src_install() {
	# install php-select
	dosbin php-select || die

	dodir /usr/share/php-select
	insinto /usr/share/php-select
	doins php-select-modules/*
}
