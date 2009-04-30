# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/lapack/lapack-3.1.ebuild,v 1.3 2008/12/07 19:10:48 vapier Exp $

DESCRIPTION="Virtual for Linear Algebra Package FORTRAN 77 (LAPACK) implementation"
HOMEPAGE="http://www.gentoo.org/proj/en/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE=""

RDEPEND="|| (
		>=sci-libs/lapack-reference-3.1
		>=sci-libs/lapack-atlas-3.8.0
		>=sci-libs/mkl-10
		>=sci-libs/acml-4
	)"
DEPEND=""
