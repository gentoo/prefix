# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-dicts/edictionary/edictionary-2.2.ebuild,v 1.5 2007/08/25 22:30:05 vapier Exp $

MY_PN="edict"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Command line dictionary and thesaurus"
HOMEPAGE="http://edictionary.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

RDEPEND=""
DEPEND="dev-lang/perl"

S="${WORKDIR}/${MY_PN}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e '1c\#!'"${EPREFIX}"'/usr/bin/perl -W' edict || die
}

src_install() {
	make prefix="${ED}/usr/bin" install || die "make failed"
	dodoc README TODO || die
}
