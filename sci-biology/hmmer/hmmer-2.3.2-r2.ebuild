# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/hmmer/hmmer-2.3.2-r2.ebuild,v 1.7 2008/02/07 14:39:22 grobian Exp $

EAPI="prefix"

DESCRIPTION="Sequence analysis using profile hidden Markov models"
LICENSE="GPL-2"
HOMEPAGE="http://hmmer.janelia.org/"
SRC_URI="ftp://ftp.genetics.wustl.edu/pub/eddy/${PN}/${PV}/${P}.tar.gz"

SLOT="0"
IUSE="pvm threads"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"

DEPEND="pvm? ( sys-cluster/pvm )"

src_compile() {
	econf \
		--host=${CHOST} \
		--prefix=${ED}/usr \
		--exec_prefix=${ED}/usr \
		--mandir=${ED}/usr/share/man \
		--enable-lfs \
		$(use_enable pvm) \
		$(use_enable threads) || die
	emake || die
}

src_install() {
	einstall || die

	cd src
	dolib libhmmer.a
	insinto /usr/include/hmmer
	doins *.h

	cd ../squid
	dobin afetch alistat compalign compstruct revcomp seqstat seqsplit sfetch shuffle sreformat sindex weight translate
	dolib libsquid.a
	insinto /usr/include/hmmer
	doins *.h

	cd ..
	dodoc NOTES
	newdoc 00README README
	insinto /usr/share/doc/${PF}
	doins Userguide.pdf
}

src_test() {
	make check
}
