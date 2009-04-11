# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/embassy-mse/embassy-mse-1.0.0-r6.ebuild,v 1.1 2008/08/27 19:39:51 ribosome Exp $

EBOV="6.0.1"

inherit embassy

DESCRIPTION="EMBOSS integrated version of MSE - Multiple Sequence Screen Editor"
SRC_URI="ftp://emboss.open-bio.org/pub/EMBOSS/EMBOSS-${EBOV}.tar.gz
	mirror://gentoo/embassy-${EBOV}-${PN:8}-${PV}.tar.gz"

KEYWORDS="~x86-linux ~ppc-macos"

src_install() {
	embassy_src_install
	insinto /usr/include/emboss/mse
	doins h/*.h
}
