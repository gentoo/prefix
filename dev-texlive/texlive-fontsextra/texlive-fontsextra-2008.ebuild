# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-texlive/texlive-fontsextra/texlive-fontsextra-2008.ebuild,v 1.10 2009/03/18 20:59:32 ranger Exp $

TEXLIVE_MODULE_CONTENTS="Asana-Math accfonts albertus aleph allrunes antiqua antp antt apl ar archaic arev ascii astro atqolive augie auncial-new aurical barcodes bayer bbding bbm bbm-macros bbold belleek bera blacklettert1 boisik bookhands braille brushscr calligra carolmin-ps cherokee cirth clarendo cm-lgc cm-super cmastro cmbright cmll cmpica coronet courier-scaled cryst cyklop dancers dice dictsym dingbat doublestroke duerer duerer-latex ean ecc eco eiad elvish epigrafica epsdice esvect eulervm euxm feyn fge foekfont fonetika fourier fouriernc frcursive futhark garamond genealogy gfsartemisia gfsbodoni gfscomplutum gfsdidot gfsneohellenic gfssolomos gothic greenpoint groff grotesq hands hfbright hfoldsty ifsym initials iwona kixfont knuthotherfonts kpfonts kurier lettrgth lfb libertine linearA logic lxfonts ly1 marigold mathdesign mnsymbol nkarta oca ocherokee ogham oinuit optima osmanian pacioli pclnfss phaistos phonetic psafm punk sauter sauterfonts semaphor simpsons skull staves tapir tengwarscript tpslifonts trajan umrand umtypewriter univers universa wsuipa yfonts zefonts collection-fontsextra
"
TEXLIVE_MODULE_DOC_CONTENTS="Asana-Math.doc accfonts.doc aleph.doc allrunes.doc antiqua.doc antp.doc antt.doc ar.doc archaic.doc arev.doc ascii.doc astro.doc augie.doc auncial-new.doc aurical.doc barcodes.doc bayer.doc bbm.doc bbm-macros.doc bbold.doc belleek.doc bera.doc blacklettert1.doc boisik.doc bookhands.doc braille.doc brushscr.doc carolmin-ps.doc cirth.doc cm-lgc.doc cm-super.doc cmastro.doc cmbright.doc cmll.doc cmpica.doc courier-scaled.doc cryst.doc cyklop.doc dice.doc dictsym.doc dingbat.doc doublestroke.doc duerer.doc duerer-latex.doc ean.doc ecc.doc eco.doc eiad.doc elvish.doc epigrafica.doc epsdice.doc esvect.doc eulervm.doc feyn.doc fge.doc foekfont.doc fonetika.doc fourier.doc fouriernc.doc frcursive.doc futhark.doc genealogy.doc gfsartemisia.doc gfsbodoni.doc gfscomplutum.doc gfsdidot.doc gfsneohellenic.doc gfssolomos.doc gothic.doc greenpoint.doc grotesq.doc hfbright.doc hfoldsty.doc ifsym.doc initials.doc iwona.doc kixfont.doc kpfonts.doc kurier.doc lfb.doc libertine.doc linearA.doc logic.doc lxfonts.doc ly1.doc mathdesign.doc mnsymbol.doc nkarta.doc ocherokee.doc ogham.doc oinuit.doc pacioli.doc pclnfss.doc phaistos.doc phonetic.doc sauterfonts.doc semaphor.doc staves.doc tapir.doc tengwarscript.doc tpslifonts.doc trajan.doc umrand.doc umtypewriter.doc universa.doc wsuipa.doc yfonts.doc zefonts.doc "
TEXLIVE_MODULE_SRC_CONTENTS="allrunes.source apl.source archaic.source arev.source ascii.source augie.source auncial-new.source barcodes.source bayer.source bbding.source bbm.source bbm-macros.source bbold.source belleek.source blacklettert1.source bookhands.source braille.source brushscr.source cmbright.source cmll.source dingbat.source eco.source eiad.source epsdice.source esvect.source eulervm.source feyn.source fge.source fourier.source frcursive.source hfbright.source hfoldsty.source linearA.source mnsymbol.source oinuit.source pacioli.source pclnfss.source phaistos.source phonetic.source sauterfonts.source skull.source staves.source tengwarscript.source trajan.source universa.source wsuipa.source yfonts.source "
inherit texlive-module
DESCRIPTION="TeXLive Extra fonts"

LICENSE="GPL-2 as-is BSD freedist GPL-1 GPL-2 LPPL-1.3 nosell OFL public-domain TeX "
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""
DEPEND=">=dev-texlive/texlive-basic-2008
!=dev-texlive/texlive-langpolish-2007*
"
RDEPEND="${DEPEND}"
