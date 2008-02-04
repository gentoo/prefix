# Copyright 2008-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit flag-o-matic

DESCRIPTION="An Interix/Cygwin to native Win32 Cross-Compiler Tool (requires Visual Studio)."
HOMEPAGE="http://www.sourceforge.net/projects/parity/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="-* ~x86-interix" # Windows only
IUSE=""

DEPEND=""
RDEPEND=""

src_compile() {
	[[ ${CHOST} == *-interix* ]] && append-flags "-D_ALL_SOURCE"

	econf
	emake || die "emake failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "make install failed"
}

