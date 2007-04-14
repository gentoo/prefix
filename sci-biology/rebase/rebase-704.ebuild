# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-biology/rebase/rebase-704.ebuild,v 1.1 2007/04/11 01:15:11 ribosome Exp $

EAPI="prefix"

DESCRIPTION="A restriction enzyme database"
LICENSE="public-domain"
HOMEPAGE="http://rebase.neb.com"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

SLOT="0"
# Minimal build keeps only the indexed files (if applicable) and the
# documentation. The non-indexed database is not installed.
IUSE="emboss minimal"
KEYWORDS="~amd64 ~ppc-macos ~x86"

DEPEND="emboss? ( >=sci-biology/emboss-3.0.0-r1 )"

src_compile() {
	if use emboss; then
		echo; einfo "Indexing Rebase for usage with EMBOSS."
		mkdir REBASE
		EMBOSS_DATA="." rebaseextract -auto -infile withrefm.${PV} \
			-protofile proto.${PV} || die "Indexing Rebase failed."
		echo
	fi
}

src_install() {
	if ! use minimal; then
		insinto /usr/share/${PN}
		doins withrefm.${PV} proto.${PV} || die \
			"Failed to install raw database."
	fi
	newdoc REBASE.DOC README || die "Failed to install documentation."
	if use emboss; then
		insinto /usr/share/EMBOSS/data/REBASE
		doins REBASE/embossre.{enz,ref,sup} || die \
			"Failed to install EMBOSS data files."
		insinto /usr/share/EMBOSS/data
		doins embossre.equ || die "Failed to install enzyme prototypes file."
	fi
}
