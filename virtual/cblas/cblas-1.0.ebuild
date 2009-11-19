# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/cblas/cblas-1.0.ebuild,v 1.6 2008/12/07 18:41:13 vapier Exp $

DESCRIPTION="Virtual for BLAS C implementation"
HOMEPAGE="http://www.gentoo.org/proj/en/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

RDEPEND="|| (
		sci-libs/cblas-reference
		>=sci-libs/blas-atlas-3.7.39
		>=sci-libs/gsl-1.9-r1
		>=sci-libs/mkl-9.1.023
	)"
DEPEND=""
