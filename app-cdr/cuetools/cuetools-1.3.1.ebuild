# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/cuetools/cuetools-1.3.1.ebuild,v 1.4 2006/12/03 07:35:17 pylon Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Utilities to manipulate and convert cue and toc files"
HOMEPAGE="http://developer.berlios.de/projects/cuetools/"
SRC_URI="http://download.berlios.de/cuetools/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}

	if use ppc; then
		cd ${S}
		epatch ${FILESDIR}/ppc.patch.bz2
	fi
}

src_install() {
	make DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS NEWS README TODO
	insinto /usr/share/doc/${PF}/extras
	doins extras/{cueconvert.cgi,cuetag.sh}
	docinto extras; dodoc extras/*.txt
}
