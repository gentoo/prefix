# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-pstricks/texlive-pstricks-2007.ebuild,v 1.17 2009/01/13 08:13:34 aballier Exp $

TEXLIVE_MODULES_DEPS="dev-texlive/texlive-basic
"
TEXLIVE_MODULE_CONTENTS="auto-pst-pdf makeplot pdftricks pst-3d pst-3dplot pst-bar pst-barcode pst-blur pst-circ pst-coil pst-dbicons pst-eps pst-eucl pst-fill pst-fr3d pst-func pst-geo pst-ghsb pst-gr3d pst-grad pst-infixplot pst-jtree pst-labo pst-lens pst-light3d pst-math pst-optic pst-osci pst-pdgr pst-poly pst-slpe pst-text pst-uml pst-vue3d pstricks pstricks-add uml collection-pstricks
"
inherit texlive-module
DESCRIPTION="TeXLive PSTricks packages"

LICENSE="GPL-2 LPPL-1.3c"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""
RDEPEND="dev-texlive/texlive-genericrecommended"
