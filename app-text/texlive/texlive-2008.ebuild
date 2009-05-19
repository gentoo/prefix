# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/texlive/texlive-2008.ebuild,v 1.14 2009/05/16 10:50:31 aballier Exp $

EAPI=2

DESCRIPTION="A complete TeX distribution"
HOMEPAGE="http://tug.org/texlive/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="cjk context cyrillic detex doc dvi2tty dvipdfm extra games graphics
	humanities jadetex latex3 music omega png pstricks publishers science tex4ht
	truetype xetex xindy xml X"

LANGS="af ar bg bn bo cs cy da de el en en_GB eo es et fi fr ga he hi hr hsb hu hy id
	is it ja ko la ml mn nl no pl pt ro ru sk sl sr sv ta th tr uk vi zh"

for X in ${LANGS}; do
	IUSE="${IUSE} linguas_${X}"
done

TEXLIVE_CAT="dev-texlive"

DEPEND=">=app-text/texlive-core-${PV}"
RDEPEND="${DEPEND}
	dev-tex/luatex
	app-text/psutils
	>=${TEXLIVE_CAT}/texlive-psutils-${PV}
	media-gfx/sam2p
	app-text/texi2html
	sys-apps/texinfo
	>=${TEXLIVE_CAT}/texlive-texinfo-${PV}
	app-text/t1utils
	dev-util/dialog
	>=app-text/lcdf-typetools-2.69[kpathsea]
	truetype? ( media-libs/freetype:1[kpathsea] )
	detex? ( dev-tex/detex )
	app-text/ps2eps
	dvipdfm? ( >=app-text/dvipdfm-0.13.2d )
	dvi2tty? ( dev-tex/dvi2tty )
	png? ( app-text/dvipng )
	X? ( >=app-text/xdvik-22.84.10 )
	>=${TEXLIVE_CAT}/texlive-basic-${PV}
	>=${TEXLIVE_CAT}/texlive-fontsrecommended-${PV}
	>=${TEXLIVE_CAT}/texlive-latex-${PV}
	latex3? ( >=${TEXLIVE_CAT}/texlive-latex3-${PV} )
	>=${TEXLIVE_CAT}/texlive-latexrecommended-${PV}
	>=dev-tex/xcolor-2.11
	>=dev-tex/latex-beamer-3.07
	>=${TEXLIVE_CAT}/texlive-metapost-${PV}
		dev-tex/feynmf
	>=${TEXLIVE_CAT}/texlive-genericrecommended-${PV}
	extra? (
		dev-tex/chktex
		>=${TEXLIVE_CAT}/texlive-bibtexextra-${PV}
		>=${TEXLIVE_CAT}/texlive-fontsextra-${PV}
		>=${TEXLIVE_CAT}/texlive-formatsextra-${PV}
		>=${TEXLIVE_CAT}/texlive-genericextra-${PV}
		>=${TEXLIVE_CAT}/texlive-latexextra-${PV}
			dev-tex/translator
			dev-tex/glossaries
			>=dev-tex/leaflet-20041222
			>=dev-tex/currvita-0.9i-r1
			>=dev-tex/g-brief-4.0.2
			>=dev-tex/envlab-1.2-r1
			>=dev-tex/europecv-20060424-r1
			>=dev-tex/svninfo-0.7.3-r1
		>=${TEXLIVE_CAT}/texlive-mathextra-${PV}
			>=dev-tex/mh-20080903
		>=${TEXLIVE_CAT}/texlive-plainextra-${PV}
	)
	xetex? ( >=${TEXLIVE_CAT}/texlive-xetex-${PV} )
	graphics? ( >=${TEXLIVE_CAT}/texlive-pictures-${PV}
		>=dev-tex/pgf-2.00 )
	science? ( >=${TEXLIVE_CAT}/texlive-science-${PV} )
	publishers? ( >=${TEXLIVE_CAT}/texlive-publishers-${PV} )
	music? ( >=${TEXLIVE_CAT}/texlive-music-${PV} )
	pstricks? ( >=${TEXLIVE_CAT}/texlive-pstricks-${PV} )
	omega? ( >=${TEXLIVE_CAT}/texlive-omega-${PV} )
	context? ( >=${TEXLIVE_CAT}/texlive-context-${PV} )
	games? ( >=${TEXLIVE_CAT}/texlive-games-${PV} )
	humanities? ( >=${TEXLIVE_CAT}/texlive-humanities-${PV} )
	tex4ht? ( >=dev-tex/tex4ht-20080829 )
	xml? (
		>=${TEXLIVE_CAT}/texlive-htmlxml-${PV}
		>=dev-tex/xmltex-1.9-r2
		app-text/passivetex
	)
	jadetex? ( >=app-text/jadetex-3.13-r2 )
	doc? (
		>=${TEXLIVE_CAT}/texlive-documentation-base-${PV}
		linguas_bg? ( >=${TEXLIVE_CAT}/texlive-documentation-bulgarian-${PV} )
		linguas_zh? ( >=${TEXLIVE_CAT}/texlive-documentation-chinese-${PV} )
		linguas_cs? ( >=${TEXLIVE_CAT}/texlive-documentation-czechslovak-${PV} )
		linguas_sk? ( >=${TEXLIVE_CAT}/texlive-documentation-czechslovak-${PV} )
		linguas_nl? ( >=${TEXLIVE_CAT}/texlive-documentation-dutch-${PV} )
		linguas_en? ( >=${TEXLIVE_CAT}/texlive-documentation-english-${PV} )
		linguas_fi? ( >=${TEXLIVE_CAT}/texlive-documentation-finnish-${PV} )
		linguas_fr? ( >=${TEXLIVE_CAT}/texlive-documentation-french-${PV} )
		linguas_de? ( >=${TEXLIVE_CAT}/texlive-documentation-german-${PV} )
		linguas_el? ( >=${TEXLIVE_CAT}/texlive-documentation-greek-${PV} )
		linguas_it? ( >=${TEXLIVE_CAT}/texlive-documentation-italian-${PV} )
		linguas_ja? ( >=${TEXLIVE_CAT}/texlive-documentation-japanese-${PV} )
		linguas_ko? ( >=${TEXLIVE_CAT}/texlive-documentation-korean-${PV} )
		linguas_mn? ( >=${TEXLIVE_CAT}/texlive-documentation-mongolian-${PV} )
		linguas_pl? ( >=${TEXLIVE_CAT}/texlive-documentation-polish-${PV} )
		linguas_pt? ( >=${TEXLIVE_CAT}/texlive-documentation-portuguese-${PV} )
		linguas_ru? ( >=${TEXLIVE_CAT}/texlive-documentation-russian-${PV} )
		linguas_sl? ( >=${TEXLIVE_CAT}/texlive-documentation-slovenian-${PV} )
		linguas_es? ( >=${TEXLIVE_CAT}/texlive-documentation-spanish-${PV} )
		linguas_th? ( >=${TEXLIVE_CAT}/texlive-documentation-thai-${PV} )
		linguas_tr? ( >=${TEXLIVE_CAT}/texlive-documentation-turkish-${PV} )
		linguas_uk? ( >=${TEXLIVE_CAT}/texlive-documentation-ukrainian-${PV} )
		linguas_vi? ( >=${TEXLIVE_CAT}/texlive-documentation-vietnamese-${PV} )
	)
	linguas_af? ( >=${TEXLIVE_CAT}/texlive-langafrican-${PV} )
	linguas_ar? ( >=${TEXLIVE_CAT}/texlive-langarab-${PV} )
	linguas_hy? ( >=${TEXLIVE_CAT}/texlive-langarmenian-${PV} )
	cjk? ( >=${TEXLIVE_CAT}/texlive-langcjk-${PV}
		>=dev-tex/cjk-latex-4.8.1 )
	linguas_hr? ( >=${TEXLIVE_CAT}/texlive-langcroatian-${PV} )
	cyrillic? ( >=${TEXLIVE_CAT}/texlive-langcyrillic-${PV} )
	linguas_cs? ( >=${TEXLIVE_CAT}/texlive-langczechslovak-${PV} >=app-text/vlna-1.3 )
	linguas_sk? ( >=${TEXLIVE_CAT}/texlive-langczechslovak-${PV} )
	linguas_da? ( >=${TEXLIVE_CAT}/texlive-langdanish-${PV} )
	linguas_nl? ( >=${TEXLIVE_CAT}/texlive-langdutch-${PV} )
	linguas_fi? ( >=${TEXLIVE_CAT}/texlive-langfinnish-${PV} )
	linguas_fr? ( >=${TEXLIVE_CAT}/texlive-langfrench-${PV} )
	linguas_de? ( >=${TEXLIVE_CAT}/texlive-langgerman-${PV} )
	linguas_el? ( >=${TEXLIVE_CAT}/texlive-langgreek-${PV} )
	linguas_he? ( >=${TEXLIVE_CAT}/texlive-langhebrew-${PV} )
	linguas_hu? ( >=${TEXLIVE_CAT}/texlive-langhungarian-${PV} )
	linguas_bn? ( >=${TEXLIVE_CAT}/texlive-langindic-${PV} )
	linguas_ml? ( >=${TEXLIVE_CAT}/texlive-langindic-${PV} )
	linguas_ta? ( >=${TEXLIVE_CAT}/texlive-langindic-${PV} )
	linguas_hi? ( >=${TEXLIVE_CAT}/texlive-langindic-${PV} )
	linguas_it? ( >=${TEXLIVE_CAT}/texlive-langitalian-${PV} )
	linguas_la? ( >=${TEXLIVE_CAT}/texlive-langlatin-${PV} )
	linguas_mn? ( >=${TEXLIVE_CAT}/texlive-langmongolian-${PV} )
	linguas_no? ( >=${TEXLIVE_CAT}/texlive-langnorwegian-${PV} )
	linguas_eo? ( >=${TEXLIVE_CAT}/texlive-langother-${PV} )
	linguas_et? ( >=${TEXLIVE_CAT}/texlive-langother-${PV} )
	linguas_ga? ( >=${TEXLIVE_CAT}/texlive-langother-${PV} )
	linguas_is? ( >=${TEXLIVE_CAT}/texlive-langother-${PV} )
	linguas_id? ( >=${TEXLIVE_CAT}/texlive-langother-${PV} )
	linguas_ro? ( >=${TEXLIVE_CAT}/texlive-langother-${PV} )
	linguas_sr? ( >=${TEXLIVE_CAT}/texlive-langother-${PV} )
	linguas_sl? ( >=${TEXLIVE_CAT}/texlive-langother-${PV} )
	linguas_tr? ( >=${TEXLIVE_CAT}/texlive-langother-${PV} )
	linguas_hsb? ( >=${TEXLIVE_CAT}/texlive-langother-${PV} )
	linguas_cy? ( >=${TEXLIVE_CAT}/texlive-langother-${PV} )
	linguas_pl? ( >=${TEXLIVE_CAT}/texlive-langpolish-${PV} )
	linguas_pt? ( >=${TEXLIVE_CAT}/texlive-langportuguese-${PV} )
	linguas_es? ( >=${TEXLIVE_CAT}/texlive-langspanish-${PV} )
	linguas_sv? ( >=${TEXLIVE_CAT}/texlive-langswedish-${PV} )
	linguas_bo? ( >=${TEXLIVE_CAT}/texlive-langtibetan-${PV} )
	linguas_en_GB? ( >=${TEXLIVE_CAT}/texlive-langukenglish-${PV} )
	linguas_vi? ( >=${TEXLIVE_CAT}/texlive-langvietnamese-${PV} )
	xindy? ( app-text/xindy )
"
