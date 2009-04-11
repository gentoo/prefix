# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/embassy-mse/embassy-mse-1.0.0-r4.ebuild,v 1.4 2007/07/18 02:40:41 ribosome Exp $

EBOV="4.0.0"

inherit embassy

DESCRIPTION="EMBOSS integrated version of MSE - Multiple Sequence Screen Editor"
SRC_URI="ftp://emboss.open-bio.org/pub/EMBOSS/EMBOSS-${EBOV}.tar.gz
	mirror://gentoo/embassy-${EBOV}-${PN:8}-${PV}.tar.gz"

KEYWORDS="~x86-linux ~ppc-macos"

src_install() {
	sed -e "s:libdir = \${exec_prefix}/lib:libdir = \${exec_prefix}/$(get_libdir):g" \
			-i ckit/Makefile || die "Failed patching Makefile."
	embassy_src_install
	insinto /usr/include/emboss/mse
	doins h/*.h
}
