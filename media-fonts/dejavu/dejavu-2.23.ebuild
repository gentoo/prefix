# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/dejavu/dejavu-2.23.ebuild,v 1.3 2008/03/18 14:00:23 cardoe Exp $

EAPI="prefix"

inherit font versionator

DESCRIPTION="DejaVu fonts, bitstream vera with ISO-8859-2 characters"
HOMEPAGE="http://dejavu.sourceforge.net/"
LICENSE="BitstreamVera"

# If you want to test snapshot from dejavu.sf.net/snapshots/
# just rename ebuild to dejavu-2.22.20071220.2156.ebuild
MY_PV=$(get_version_component_range 1-2)
snapv=$(get_version_component_range 3-4)
snapv=${snapv/./-}
MY_P=${PN}-fonts-ttf-${MY_PV}

[[ -z ${snapv} ]] && {
	SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2" ;
	S=${WORKDIR}/${MY_P} ;
} || {
	SRC_URI="http://dejavu.sourceforge.net/snapshots/${MY_P}-${snapv}.tar.bz2" ;
	S=${WORKDIR}/${MY_P}-${snapv} ;
}

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE=""

DOCS="AUTHORS BUGS NEWS README status.txt langcover.txt unicover.txt"
FONT_SUFFIX="ttf"
FONT_S=${S}/ttf

# Only installs fonts
RESTRICT="strip binchecks"

pkg_postinst() {
	font_pkg_postinst

	ewarn
	ewarn "Starting with ${PN}-2.22 font ligatures were re-imported in DejaVu"
	ewarn "That means that you'll possibly encounter infamous ligature bug with"
	ewarn "pango-enabled Firefox (e.g. 'fi' and 'fl' will occasionally overlap)."
	ewarn "This will be fixed in Firefox-3.x. Until this happens either use"
	ewarn "Firefox without pango (MOZ_DISABLE_PANGO=1), or use ${PN}-2.21"
	ewarn
}

FONT_CONF=( "${S}/fontconfig/20-unhint-small-dejavu.conf"
			"${S}/fontconfig/20-unhint-small-dejavu-experimental.conf"
			"${S}/fontconfig/57-dejavu.conf"
			"${S}/fontconfig/61-dejavu-experimental.conf" )
