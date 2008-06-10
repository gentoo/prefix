# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-chemistry/moldy/moldy-2.16e.ebuild,v 1.9 2008/06/09 10:30:12 markusle Exp $

EAPI="prefix"

IUSE=""

S=${WORKDIR}
DESCRIPTION="Program for performing molecular dynamics simulations."
SRC_URI="ftp://ftp.earth.ox.ac.uk/pub/keith/${P}.tar.gz"
#For lack of a better homepage
HOMEPAGE="http://www.earth.ox.ac.uk/~keithr/moldy.html"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-linux ~ppc-macos"

DEPEND="virtual/libc
	virtual/latex-base"

src_compile() {
#Individuals may want to edit the OPT* variables below.
#From the READ.ME:
#You may need to  "hand-tune" compiler or optimization options,
#which may be specified by setting the OPT and OPT2 environment
#variables.  OPT2 is used to compile only the most performance-critical
#modules and usually will select a very high level of optimization.
#It should be safe to select an optimization which means "treat all
#function arguments as restricted pointers which are not aliased to
#any other object".  OPT is used for less preformance-critical modules
#and may be set to a lower level of optimization than OPT2.

	OPT=${CFLAGS} OPT2=${CFLAGS} \
	./configure --prefix="${EPREFIX}"/usr \
		--host=${CHOST} \
		|| die

	emake || die
	# To prevent sandbox violations by metafont
	VARTEXFONTS="${T}"/fonts make moldy.pdf || die
}

src_install() {
	dodir /usr/bin
	make prefix="${ED}"/usr install || die
	rm Makefile.in configure.in config.h.in
	insinto /usr/share/${PN}/examples/
	doins *.in *.out control.*
	dodoc BENCHMARK READ.ME RELNOTES
	insinto /usr/share/doc/${P}/pdf
	newins moldy.pdf moldy-manual.pdf
}
