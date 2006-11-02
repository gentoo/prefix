# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/prints/prints-38.0.ebuild,v 1.7 2006/08/18 02:48:20 weeve Exp $

EAPI="prefix"

MY_PV="${PV/./_}"

DESCRIPTION="A protein motif fingerprint database"
LICENSE="public-domain"
HOMEPAGE="http://www.bioinf.man.ac.uk/dbbrowser/PRINTS/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

SLOT="0"
IUSE="emboss minimal"
# Minimal build keeps only the indexed files (if applicable) and the
# documentation. The non-indexed database is not installed.
KEYWORDS="~amd64 ~ppc-macos ~x86"

DEPEND="emboss? ( sci-biology/emboss )"

src_compile() {
	if use emboss; then
		mkdir PRINTS
		echo
		einfo "Indexing PRINTS for usage with EMBOSS."
		EMBOSS_DATA="." printsextract -auto -infile prints${MY_PV}.dat || die \
			"Indexing PRINTS failed."
		echo
	fi
}

src_install() {
	if ! use minimal; then
		insinto /usr/share/${PN}
		doins newpr.lis ${PN}${MY_PV}.{all.fasta,dat,kdat,lis,nam,vsn} || die \
			"Installing raw database failed."
	fi
	if use emboss; then
		insinto /usr/share/EMBOSS/data/PRINTS
		doins PRINTS/* || die "Installing EMBOSS data files failed."
	fi
	dodoc README || die "Documentation installation failed."
}
