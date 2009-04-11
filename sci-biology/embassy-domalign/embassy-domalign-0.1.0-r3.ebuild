# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/embassy-domalign/embassy-domalign-0.1.0-r3.ebuild,v 1.1 2008/08/27 19:56:31 ribosome Exp $

EBOV="6.0.1"

inherit embassy

DESCRIPTION="Protein domain alignment add-on package for EMBOSS"
SRC_URI="ftp://emboss.open-bio.org/pub/EMBOSS/EMBOSS-${EBOV}.tar.gz
	mirror://gentoo/embassy-${EBOV}-${PN:8}-${PV}.tar.gz"

KEYWORDS="~x86-linux ~ppc-macos"
