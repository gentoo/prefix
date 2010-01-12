# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-science/texlive-science-2009.ebuild,v 1.1 2010/01/11 03:34:39 aballier Exp $

TEXLIVE_MODULE_CONTENTS="SIstyle SIunits alg algorithm2e algorithmicx algorithms biocon bpchem bytefield chemarrow chemcompounds chemcono chemstyle clrscode complexity computational-complexity digiconfigs dyntree eltex formula fouridx functan galois gastex gene-logic gu hep hepnames hepparticles hepthesis hepunits karnaugh mhchem mhs miller objectz pseudocode scientificpaper sciposter sfg siunitx steinmetz struktex t-angles textopo ulqda unitsdef youngtab collection-science
"
TEXLIVE_MODULE_DOC_CONTENTS="SIstyle.doc SIunits.doc alg.doc algorithm2e.doc algorithmicx.doc algorithms.doc biocon.doc bpchem.doc bytefield.doc chemarrow.doc chemcompounds.doc chemcono.doc chemstyle.doc clrscode.doc complexity.doc computational-complexity.doc digiconfigs.doc dyntree.doc eltex.doc formula.doc fouridx.doc functan.doc galois.doc gastex.doc gene-logic.doc gu.doc hep.doc hepnames.doc hepparticles.doc hepthesis.doc hepunits.doc karnaugh.doc mhchem.doc miller.doc objectz.doc pseudocode.doc scientificpaper.doc sciposter.doc sfg.doc siunitx.doc steinmetz.doc struktex.doc t-angles.doc textopo.doc ulqda.doc unitsdef.doc "
TEXLIVE_MODULE_SRC_CONTENTS="SIstyle.source SIunits.source alg.source algorithms.source bpchem.source bytefield.source chemcompounds.source chemstyle.source computational-complexity.source dyntree.source formula.source fouridx.source functan.source galois.source hepthesis.source miller.source objectz.source siunitx.source steinmetz.source struktex.source textopo.source ulqda.source unitsdef.source youngtab.source "
inherit texlive-module
DESCRIPTION="TeXLive Typesetting for natural and computer sciences"

LICENSE="GPL-2 as-is GPL-1 LGPL-2 LPPL-1.3 public-domain "
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris"
IUSE=""
DEPEND=">=dev-texlive/texlive-latex-2009
!dev-tex/SIunits
"
RDEPEND="${DEPEND} dev-texlive/texlive-pstricks
"
TEXLIVE_MODULE_BINSCRIPTS="texmf-dist/scripts/ulqda/ulqda.pl"
