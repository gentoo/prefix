# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/embassy-memenew/embassy-memenew-0.1.0.ebuild,v 1.5 2006/11/03 13:15:24 nixnut Exp $

EAPI="prefix"

EBOV="4.0.0"

inherit embassy

DESCRIPTION="EMBOSS integrated version of MEME - Multiple Em for Motif Elicitation"
SRC_URI="ftp://emboss.open-bio.org/pub/EMBOSS/EMBOSS-${EBOV}.tar.gz
	mirror://gentoo/embassy-${EBOV}-${PN:8}-${PV}.tar.gz"

KEYWORDS="~ppc-macos ~x86"

src_install() {
	embassy_src_install
	insinto /usr/include/emboss/meme
	doins src/INCLUDE/*.h
}
