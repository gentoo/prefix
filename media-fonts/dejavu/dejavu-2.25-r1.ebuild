# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/dejavu/dejavu-2.25-r1.ebuild,v 1.2 2008/06/02 01:27:23 mr_bones_ Exp $

EAPI="prefix 1"

inherit font

DESCRIPTION="DejaVu fonts, bitstream vera with ISO-8859-2 characters"
HOMEPAGE="http://dejavu.sourceforge.net/"
LICENSE="BitstreamVera"

MY_BP=${PN}-fonts-ttf-${PV}
MY_SP=${PN}-fonts-${PV}
SRC_URI="!fontforge? (  mirror://sourceforge/${PN}/${MY_BP}.tar.bz2 )
	fontforge? ( mirror://sourceforge/${PN}/${MY_SP}.tar.bz2 )"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"

IUSE="+fontforge"
DEPEND="fontforge? ( x11-apps/mkfontscale
		>=media-gfx/fontforge-20080429
		x11-apps/mkfontdir
		dev-perl/Font-TTF
		app-i18n/unicode-data
		>media-libs/fontconfig-2.5.93 )"
RDEPEND=""

if use fontforge
then
	S=${WORKDIR}/${MY_SP}
	FONT_S=${S}/build
else
	S=${WORKDIR}/${MY_BP}
	FONT_S=${S}/ttf
fi
FONT_CONF=( 	"${S}/fontconfig/20-unhint-small-dejavu.conf"
		"${S}/fontconfig/20-unhint-small-dejavu-experimental.conf"
		"${S}/fontconfig/57-dejavu.conf"
		"${S}/fontconfig/61-dejavu-experimental.conf" )
FONT_SUFFIX="ttf"
DOCS="AUTHORS NEWS README status.txt langcover.txt unicover.txt"

src_compile() {
	if use fontforge
	then
		emake -j1 \
			BLOCKS=/usr/share/unicode-data/Blocks.txt \
			UNICODEDATA=/usr/share/unicode-data/UnicodeData.txt \
			FC-LANG=/usr/share/fc-lang \
			full sans \
			|| die "emake failed"
	fi
}

src_install() {
	font_src_install
	if use fontforge
	then
		dodoc build/*.txt
	fi

}

pkg_postinst() {
	font_pkg_postinst

	ewarn
	ewarn "Starting with ${PN}-2.22 font ligatures were re-imported in DejaVu"
	ewarn "That means that you'll possibly encounter the infamous ligature bug"
	ewarn "with pango-enabled Firefox (e.g. 'fi' and 'fl' will occasionally"
	ewarn "overlap). This will be fixed in Firefox-3.x. Until this happens"
	ewarn "either use Firefox without pango (MOZ_DISABLE_PANGO=1), or use"
	ewarn "${PN}-2.21"
	ewarn
}
