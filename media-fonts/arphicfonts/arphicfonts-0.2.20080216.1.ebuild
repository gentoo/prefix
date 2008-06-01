# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/arphicfonts/arphicfonts-0.2.20080216.1.ebuild,v 1.2 2008/05/31 04:51:56 mr_bones_ Exp $

EAPI="prefix"

inherit font

DESCRIPTION="Chinese TrueType Arphic Fonts"
HOMEPAGE="http://www.arphic.com.tw/
	http://www.freedesktop.org/wiki/Software/CJKUnifonts"
SRC_URI="mirror://gnu/non-gnu/chinese-fonts-truetype/gkai00mp.ttf.gz
	mirror://gnu/non-gnu/chinese-fonts-truetype/bkai00mp.ttf.gz
	mirror://gnu/non-gnu/chinese-fonts-truetype/bsmi00lp.ttf.gz
	mirror://gnu/non-gnu/chinese-fonts-truetype/gbsn00lp.ttf.gz
	mirror://ubuntu/pool/main/t/ttf-arphic-uming/ttf-arphic-uming_${PV}.orig.tar.gz
	mirror://ubuntu/pool/main/t/ttf-arphic-ukai/ttf-arphic-ukai_${PV}.orig.tar.gz"

LICENSE="Arphic"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

S="${WORKDIR}"

#No binaries, only fonts
RESTRICT="strip binchecks"

FONT_S="${S}"
FONT_SUFFIX="ttc ttf"
FONT_CONF=(	"25-ttf-arphic-ukai-render.conf"
		"35-ttf-arphic-ukai-aliases.conf"
		"41-ttf-arphic-ukai.conf"
		"75-ttf-arphic-ukai-select.conf"
		"90-ttf-arphic-ukai-embolden.conf"
		"25-ttf-arphic-uming-bitmaps.conf"
		"25-ttf-arphic-uming-render.conf"
		"35-ttf-arphic-uming-aliases.conf"
		"41-ttf-arphic-uming.conf"
		"64-ttf-arphic-uming.conf"
		"90-ttf-arphic-uming-embolden.conf" )

src_unpack() {
	#All of this is to ensure that we don't overwrite one font's docs
	#with another's.

	unpack {gk,bk}ai00mp.ttf.gz {bsmi,gbsn}00lp.ttf.gz
	mkdir "${WORKDIR}"/{uming,ukai}

	cd "${WORKDIR}"/uming
	unpack ttf-arphic-uming_${PV}.orig.tar.gz

	cd "${WORKDIR}"/ukai
	unpack ttf-arphic-ukai_${PV}.orig.tar.gz

	cd "${WORKDIR}"
	find "${WORKDIR}" -mindepth 2 -maxdepth 2 -name '*.ttc' -exec mv {} . \;
	find "${WORKDIR}" -name '*.conf' -exec mv "{}" . \;
}

src_install() {
	local myfont doc
	for myfont in ukai uming
	do
		cd "${WORKDIR}"/${myfont}
		docinto ${myfont}
		for doc in  FONTLOG KNOWN_ISSUES TODO README README.Bitmap NEWS CONTRIBUTERS
		do
			[ -f ${doc} ] && dodoc ${doc}
		done
	done
	cd "${S}"
	font_src_install
}

pkg_postinst() {
	font_pkg_postinst
	if use X
	then
		elog 'This package supplies fontconfig configuration files'
		elog 'which may produce output preferable to the default.'
		elog 'These are the files supplied:'
		elog '	25-ttf-arphic-ukai-render.conf'
		elog '	35-ttf-arphic-ukai-aliases.conf'
		elog '	41-ttf-arphic-ukai.conf'
		elog '	75-ttf-arphic-ukai-select.conf'
		elog '	90-ttf-arphic-ukai-embolden.conf'
		elog '	25-ttf-arphic-uming-bitmaps.conf'
		elog '	25-ttf-arphic-uming-render.conf'
		elog '	35-ttf-arphic-uming-aliases.conf'
		elog '	41-ttf-arphic-uming.conf'
		elog '	64-ttf-arphic-uming.conf'
		elog '	90-ttf-arphic-uming-embolden.conf'
		elog 'To enable one of them, do (for example):'
		elog '	eselect fontconfig 90-ttf-arphic-uming-embolden.conf enable'
	fi
}
