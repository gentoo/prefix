# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-pstricks/texlive-pstricks-2008-r1.ebuild,v 1.10 2009/03/18 21:17:55 ranger Exp $

TEXLIVE_MODULE_CONTENTS="auto-pst-pdf makeplot pdftricks pst-2dplot pst-3d pst-3dplot pst-asr pst-bar pst-barcode pst-blur pst-circ pst-coil pst-cox pst-dbicons pst-diffraction pst-eps pst-eucl pst-fill pst-fr3d pst-fractal pst-fun pst-func pst-geo pst-ghsb pst-gr3d pst-grad pst-infixplot pst-jtree pst-labo pst-lens pst-light3d pst-math pst-ob3d pst-optexp pst-optic pst-osci pst-pad pst-pdgr pst-poly pst-qtree pst-slpe pst-spectra pst-stru pst-solides3d pst-soroban pst-text pst-uml pst-vue3d pst2pdf pstricks pstricks-add uml collection-pstricks
"
TEXLIVE_MODULE_DOC_CONTENTS="auto-pst-pdf.doc makeplot.doc pdftricks.doc pst-2dplot.doc pst-3d.doc pst-3dplot.doc pst-asr.doc pst-bar.doc pst-barcode.doc pst-blur.doc pst-circ.doc pst-coil.doc pst-cox.doc pst-dbicons.doc pst-diffraction.doc pst-eps.doc pst-eucl.doc pst-fill.doc pst-fr3d.doc pst-fractal.doc pst-fun.doc pst-func.doc pst-geo.doc pst-ghsb.doc pst-gr3d.doc pst-grad.doc pst-infixplot.doc pst-jtree.doc pst-labo.doc pst-lens.doc pst-light3d.doc pst-math.doc pst-ob3d.doc pst-optexp.doc pst-optic.doc pst-osci.doc pst-pad.doc pst-pdgr.doc pst-poly.doc pst-qtree.doc pst-slpe.doc pst-spectra.doc pst-stru.doc pst-solides3d.doc pst-soroban.doc pst-text.doc pst-uml.doc pst-vue3d.doc pst2pdf.doc pstricks.doc pstricks-add.doc uml.doc "
TEXLIVE_MODULE_SRC_CONTENTS="auto-pst-pdf.source makeplot.source pst-3d.source pst-3dplot.source pst-barcode.source pst-blur.source pst-circ.source pst-coil.source pst-dbicons.source pst-diffraction.source pst-eps.source pst-fill.source pst-fr3d.source pst-fractal.source pst-fun.source pst-func.source pst-gr3d.source pst-lens.source pst-light3d.source pst-ob3d.source pst-optic.source pst-pad.source pst-pdgr.source pst-poly.source pst-slpe.source pst-soroban.source pst-text.source pst-uml.source pst-vue3d.source pstricks-add.source uml.source "
inherit texlive-module
DESCRIPTION="TeXLive PSTricks packages"

LICENSE="GPL-2 as-is GPL-1 LGPL-2 LPPL-1.3 "
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""
DEPEND=">=dev-texlive/texlive-basic-2008
"
RDEPEND="${DEPEND} dev-texlive/texlive-genericrecommended
"
TEXLIVE_MODULE_BINSCRIPTS="texmf-dist/scripts/pst2pdf/pst2pdf.pl"
