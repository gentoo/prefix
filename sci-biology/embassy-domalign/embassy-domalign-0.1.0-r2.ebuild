# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/embassy-domalign/embassy-domalign-0.1.0-r2.ebuild,v 1.1 2007/07/18 01:22:31 ribosome Exp $

EAPI="prefix"

EBOV="5.0.0"

inherit embassy

DESCRIPTION="Protein domain alignment add-on package for EMBOSS"
SRC_URI="ftp://emboss.open-bio.org/pub/EMBOSS/EMBOSS-${EBOV}.tar.gz
	mirror://gentoo/embassy-${EBOV}-${PN:8}-${PV}.tar.gz"

KEYWORDS="~x86-linux ~ppc-macos"
