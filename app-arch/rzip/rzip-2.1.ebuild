# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/rzip/rzip-2.1.ebuild,v 1.10 2008/05/23 23:12:17 darkside Exp $

EAPI="prefix"

inherit autotools eutils

DESCRIPTION="compression program for large files"
HOMEPAGE="http://rzip.samba.org"
SRC_URI="http://rzip.samba.org/ftp/rzip/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND="app-arch/bzip2"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-2.0-darwin.patch
	eautoreconf
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
}

pkg_postinst() {
	ewarn "It has been reported that this tool will fail on files >4GB"
	ewarn "Please see https://bugs.gentoo.org/show_bug.cgi?id=217552 for more"
	ewarn "information."
}
