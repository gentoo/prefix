# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/popt/popt-1.10.4-r3.ebuild,v 1.4 2006/11/12 03:55:04 vapier Exp $

EAPI="prefix"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="1.9"

inherit flag-o-matic autotools

DESCRIPTION="Parse Options - Command line parser"
HOMEPAGE="http://www.rpm.org/"
SRC_URI="ftp://jbj.org/pub/rpm-4.4.x/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="nls"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-lib64.patch
	epatch "${FILESDIR}"/${P}-regression.patch
	use nls || epatch "${FILESDIR}"/${P}-nls.patch
	eautoreconf
}

src_compile() {
	econf $(use_enable nls) || die
	emake || die "emake failed"
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc CHANGES README
}
