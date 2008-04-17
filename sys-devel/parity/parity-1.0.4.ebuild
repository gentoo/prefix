# Copyright 2008-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit flag-o-matic

DESCRIPTION="An Interix to native Win32 Cross-Compiler Tool (requires Visual Studio)."
HOMEPAGE="http://www.sourceforge.net/projects/parity/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~x86-interix"
IUSE=""

src_compile() {
	# only for interix, since _maybe_ one could use it from wine with
	# little modifications to the source.
	[[ ${CHOST} == *-interix* ]] && append-flags "-D_ALL_SOURCE"

	# parity's configure script has tons of magic to detect propper
	# visual studio installations, which would be much too much here.

	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
}

