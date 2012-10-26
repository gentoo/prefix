# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/euses/euses-2.5.9.ebuild,v 1.7 2012/10/25 19:58:33 ken69267 Exp $

EAPI=4

DESCRIPTION="look up USE flag descriptions fast"
HOMEPAGE="http://www.xs4all.nl/~rooversj/gentoo"
SRC_URI="http://www.xs4all.nl/~rooversj/gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~sparc64-solaris"
IUSE=""

DEPEND="
	ppc-aix? ( dev-libs/gnulib )
	sparc-solaris? ( dev-libs/gnulib )
	sparc64-solaris? ( dev-libs/gnulib )
	x86-solaris? ( dev-libs/gnulib )
	x64-solaris? ( dev-libs/gnulib )
"

S=${WORKDIR}

src_configure() {
	if [[ ${CHOST} == *-aix* || ${CHOST} == *-solaris* ]]; then
		append-cppflags -I"${EPREFIX}"/usr/$(get_libdir)/gnulib/include
		append-ldflags -L"${EPREFIX}"/usr/$(get_libdir)/gnulib/lib
		export LIBS="-lgnu"
	fi

	econf
}

src_install() {
	dobin ${PN}
	doman ${PN}.1
	dodoc ChangeLog
}
