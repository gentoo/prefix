# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-science/texlive-science-2008.ebuild,v 1.11 2009/03/27 19:15:56 aballier Exp $

TEXLIVE_MODULE_CONTENTS="SIstyle SIunits alg algorithm2e algorithmicx algorithms biocon bpchem bytefield chemarrow chemcompounds chemcono chemstyle clrscode complexity computational-complexity digiconfigs dyntree formula fouridx functan galois gastex gu hep hepnames hepparticles hepthesis hepunits karnaugh mhchem mhs miller newalg objectz pseudocode scientificpaper sciposter sfg siunitx struktex t-angles textopo unitsdef youngtab collection-science
"
TEXLIVE_MODULE_DOC_CONTENTS="SIstyle.doc SIunits.doc alg.doc algorithm2e.doc algorithmicx.doc algorithms.doc biocon.doc bpchem.doc bytefield.doc chemarrow.doc chemcompounds.doc chemcono.doc chemstyle.doc clrscode.doc complexity.doc computational-complexity.doc digiconfigs.doc dyntree.doc formula.doc fouridx.doc functan.doc galois.doc gastex.doc gu.doc hep.doc hepnames.doc hepparticles.doc hepthesis.doc hepunits.doc karnaugh.doc mhchem.doc miller.doc newalg.doc objectz.doc pseudocode.doc scientificpaper.doc sciposter.doc sfg.doc siunitx.doc struktex.doc t-angles.doc textopo.doc unitsdef.doc "
TEXLIVE_MODULE_SRC_CONTENTS="SIstyle.source SIunits.source alg.source biocon.source bpchem.source bytefield.source chemcompounds.source chemstyle.source computational-complexity.source dyntree.source formula.source fouridx.source functan.source galois.source hepthesis.source miller.source newalg.source objectz.source siunitx.source struktex.source textopo.source unitsdef.source youngtab.source "
inherit texlive-module
DESCRIPTION="TeXLive Typesetting for natural and computer sciences"

LICENSE="GPL-2 as-is freedist GPL-1 LGPL-2 LPPL-1.3 "
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris"
IUSE=""
DEPEND=">=dev-texlive/texlive-latex-2008
!dev-tex/SIunits
"
RDEPEND="${DEPEND} dev-texlive/texlive-pstricks"
