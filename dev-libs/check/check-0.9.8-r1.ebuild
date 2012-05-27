# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/check/check-0.9.8-r1.ebuild,v 1.10 2012/04/26 22:22:04 aballier Exp $

EAPI=4
inherit autotools autotools-utils eutils

DESCRIPTION="A unit test framework for C"
HOMEPAGE="http://sourceforge.net/projects/check/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="static-libs subunit"

DEPEND="subunit? ( dev-python/subunit )"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch \
		"${FILESDIR}"/${PN}-0.9.6-AM_PATH_CHECK.patch \
		"${FILESDIR}"/${PN}-0.9.6-64bitsafe.patch

	sed -i -e '/^docdir =/d' {.,doc}/Makefile.am || die

	# fix out-of-sourcedir build having inconsistent check.h files, for
	# example breaks USE=subunit.
	rm src/check.h || die

	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--disable-dependency-tracking
		$(use_enable subunit)
		--docdir="${EPREFIX}"/usr/share/doc/${PF}
	)
	autotools-utils_src_configure
}

src_install() {
	autotools-utils_src_install
	dodoc AUTHORS *ChangeLog* NEWS README THANKS TODO

	rm -f "${ED}"/usr/share/doc/${PF}/COPYING* || die
	find "${ED}" -name '*.la' -exec rm -f {} + || die
}
