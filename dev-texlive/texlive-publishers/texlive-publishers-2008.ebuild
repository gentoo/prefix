# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-publishers/texlive-publishers-2008.ebuild,v 1.10 2009/03/18 21:14:59 ranger Exp $

TEXLIVE_MODULE_CONTENTS="ANUfinalexam IEEEconf IEEEtran aastex acmconf acmtrans active-conf afthesis aguplus aiaa ametsoc apa asaetr ascelike chem-journal classicthesis confproc ebsthesis economic elsevier euproposal gaceta gatech-thesis har2nat icsv ieeepes ijmart imac imtekda jhep jpsj kluwer lps mentis muthesis nature nddiss nih nostarch nrc philosophersimprint pracjourn procIAGssymp ptptex revtex siggraph spie stellenbosch sugconf thesis-titlepage-fhac thuthesis toptesi tugboat tugboat-plain uaclasses ucthesis uiucthesis umthesis umich-thesis uwthesis vancouver vxu york-thesis collection-publishers
"
TEXLIVE_MODULE_DOC_CONTENTS="ANUfinalexam.doc IEEEconf.doc IEEEtran.doc aastex.doc acmconf.doc acmtrans.doc active-conf.doc afthesis.doc aguplus.doc aiaa.doc ametsoc.doc apa.doc asaetr.doc ascelike.doc classicthesis.doc confproc.doc ebsthesis.doc economic.doc elsevier.doc euproposal.doc gaceta.doc gatech-thesis.doc har2nat.doc icsv.doc ieeepes.doc ijmart.doc imac.doc imtekda.doc jpsj.doc kluwer.doc lps.doc mentis.doc muthesis.doc nature.doc nddiss.doc nih.doc nostarch.doc nrc.doc philosophersimprint.doc pracjourn.doc procIAGssymp.doc ptptex.doc revtex.doc siggraph.doc spie.doc stellenbosch.doc sugconf.doc thesis-titlepage-fhac.doc thuthesis.doc toptesi.doc tugboat.doc tugboat-plain.doc uaclasses.doc ucthesis.doc uiucthesis.doc umthesis.doc umich-thesis.doc uwthesis.doc vancouver.doc vxu.doc york-thesis.doc "
TEXLIVE_MODULE_SRC_CONTENTS="IEEEconf.source aastex.source acmconf.source active-conf.source aiaa.source asaetr.source confproc.source ebsthesis.source euproposal.source icsv.source ijmart.source imtekda.source kluwer.source lps.source mentis.source nddiss.source nostarch.source nrc.source philosophersimprint.source pracjourn.source revtex.source siggraph.source stellenbosch.source thesis-titlepage-fhac.source thuthesis.source toptesi.source tugboat.source uaclasses.source uiucthesis.source vxu.source york-thesis.source "
inherit texlive-module
DESCRIPTION="TeXLive Support for publishers and theses"

LICENSE="GPL-2 as-is freedist GPL-1 LPPL-1.3 public-domain "
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris"
IUSE=""
DEPEND=">=dev-texlive/texlive-latex-2008
"
RDEPEND="${DEPEND}"
