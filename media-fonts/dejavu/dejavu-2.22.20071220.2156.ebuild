# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/dejavu/dejavu-2.22.20071220.2156.ebuild,v 1.1 2007/12/21 13:01:22 pva Exp $

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
KEYWORDS="~amd64 ~ia64 ~sparc-solaris ~x86 ~x86-solaris"
IUSE=""

DOCS="AUTHORS BUGS NEWS README status.txt langcover.txt unicover.txt"
FONT_SUFFIX="ttf"
FONT_S=${S}/ttf

# Only installs fonts
RESTRICT="strip binchecks"

FONT_CONF="$(eval echo "${S}"/fontconfig/{20-unhint-small-dejavu.conf,20-unhint-small-dejavu-experimental.conf,57-dejavu.conf,61-dejavu-experimental.conf})"
