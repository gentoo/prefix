# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/cuetools/cuetools-1.3.1.ebuild,v 1.5 2008/06/06 21:14:19 drac Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Utilities to manipulate and convert cue and toc files"
HOMEPAGE="http://developer.berlios.de/projects/cuetools/"
SRC_URI="mirror://berlios/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	# What in earth is bzip2 archive doing in tree?
	use ppc && epatch "${FILESDIR}"/ppc.patch.bz2
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS NEWS README TODO
	insinto /usr/share/doc/${PF}/extras
	doins extras/cue{convert.cgi,tag.sh}
	docinto extras
	dodoc extras/*.txt
}
