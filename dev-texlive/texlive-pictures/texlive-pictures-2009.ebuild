# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-pictures/texlive-pictures-2009.ebuild,v 1.1 2010/01/11 03:33:10 aballier Exp $

TEXLIVE_MODULE_CONTENTS="asyfig autoarea bardiag cachepic combinedgraphics circuitikz curve curve2e curves dcpic diagmac2 doc-pictex dottex dot2texi dratex eepic epspdf epspdfconversion fig4latex gnuplottex here hvfloat miniplot pb-diagram petri-nets  pgf-soroban pgfopts pgfplots picinpar pict2e pictex pictex2 pinlabel pmgraph randbild schemabloc swimgraf texdraw tikz-inet tikz-qtree tikz-timing tkz-doc tkz-linknodes tkz-tab tufte-latex xypic collection-pictures
"
TEXLIVE_MODULE_DOC_CONTENTS="asyfig.doc autoarea.doc bardiag.doc cachepic.doc combinedgraphics.doc circuitikz.doc curve.doc curve2e.doc curves.doc dcpic.doc diagmac2.doc doc-pictex.doc dottex.doc dot2texi.doc dratex.doc eepic.doc epspdf.doc epspdfconversion.doc fig4latex.doc gnuplottex.doc here.doc hvfloat.doc miniplot.doc pb-diagram.doc petri-nets.doc pgf-soroban.doc pgfopts.doc pgfplots.doc picinpar.doc pict2e.doc pictex.doc pinlabel.doc pmgraph.doc randbild.doc schemabloc.doc swimgraf.doc texdraw.doc tikz-inet.doc tikz-qtree.doc tikz-timing.doc tkz-doc.doc tkz-linknodes.doc tkz-tab.doc tufte-latex.doc xypic.doc "
TEXLIVE_MODULE_SRC_CONTENTS="asyfig.source combinedgraphics.source curve.source curve2e.source curves.source dottex.source gnuplottex.source petri-nets.source pgfopts.source pgfplots.source pict2e.source randbild.source swimgraf.source tikz-timing.source xypic.source "
inherit texlive-module
DESCRIPTION="TeXLive Graphics packages and programs"

LICENSE="GPL-2 Apache-2.0 as-is freedist GPL-1 GPL-3 LPPL-1.3 public-domain "
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""
DEPEND=">=dev-texlive/texlive-basic-2009
!<dev-texlive/texlive-latexextra-2009
!<dev-texlive/texlive-texinfo-2009
"
RDEPEND="${DEPEND} dev-lang/ruby
"
TEXLIVE_MODULE_BINSCRIPTS="texmf-dist/scripts/cachepic/cachepic.tlu texmf-dist/scripts/epspdf/epspdf texmf-dist/scripts/epspdf/epspdftk texmf-dist/scripts/fig4latex/fig4latex"
