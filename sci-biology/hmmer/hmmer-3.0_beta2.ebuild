# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/hmmer/hmmer-3.0_beta2.ebuild,v 1.1 2009/08/30 19:04:50 weaver Exp $

EAPI="2"

MY_P="hmmer-3.0b2"

DESCRIPTION="Sequence analysis using profile hidden Markov models"
HOMEPAGE="http://hmmer.janelia.org/"
SRC_URI="ftp://selab.janelia.org/pub/software/hmmer3/${MY_P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
IUSE="sse mpi threads" # gsl
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"

# NB: compile failure with mpi, disabling temporarily
# gsl? ( sci-libs/gsl )
# mpi? ( virtual/mpi )
DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_configure() {
	econf $(use_enable sse) \
		$(use_enable threads) || die
#		$(use_enable mpi) \
#		$(use_with gsl) || die
}

src_compile() {
	emake -j1 || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dolib src/libhmmer.a || die
	dolib easel/libeasel.a || die
	insinto /usr/share/${PN}
	doins -r tutorial || die
	dodoc RELEASE-NOTES Userguide.pdf
}
