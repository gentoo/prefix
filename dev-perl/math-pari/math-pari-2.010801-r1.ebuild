# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/math-pari/math-pari-2.010801-r1.ebuild,v 1.1 2009/04/19 09:26:18 tove Exp $

EAPI=2

MODULE_AUTHOR=ILYAZ
MODULE_SECTION=modules
MY_PN=Math-Pari
MY_P=${MY_PN}-${PV}
inherit perl-module

PARI_VER=2.3.4

DESCRIPTION="Perl interface to PARI"
SRC_URI="${SRC_URI}
	http://pari.math.u-bordeaux.fr/pub/pari/unix/pari-${PARI_VER}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

# Math::Pari requires that a copy of the pari source in a parallel
# directory to where you build it. It does not need to compile it, but
# it does need to be the same version as is installed, hence the hard
# DEPEND below
# Math::Pari does NOT work with 2.3. The Makefile.PL gives warnings, and if you
# run the tests, you get failures.
RDEPEND="~sci-mathematics/pari-${PARI_VER}"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${MY_P}
SRC_TEST=do

src_prepare() {
	perl-module_src_prepare
	cd "${WORKDIR}"
	epatch "${FILESDIR}"/${P}-duplicate-object-darwin.patch
}

src_configure() {
	# Unfortunately the assembly routines math-pari has for SPARC do not appear
	# to be working at current.  Perl cannot test math-pari or anything that
	# pulls in the math-pari module as DynaLoader cannot load the resulting
	# .so files math-pari generates.  As such, we have to use the generic
	# non-machine specific assembly methods here.
	if use sparc ; then
		myconf="${myconf} machine=none"
	fi

	perl-module_src_configure
}
