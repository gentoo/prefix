# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/dejavu/dejavu-2.22.ebuild,v 1.1 2007/12/13 11:44:48 pva Exp $

EAPI="prefix"

inherit font

MY_P=${PN}-fonts-ttf-${PV}

DESCRIPTION="DejaVu fonts, bitstream vera with ISO-8859-2 characters"
HOMEPAGE="http://dejavu.sourceforge.net/"
LICENSE="BitstreamVera"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2"

SLOT="0"
KEYWORDS="~amd64 ~ia64 ~sparc-solaris ~x86 ~x86-solaris"
IUSE=""

DOCS="AUTHORS BUGS NEWS README status.txt langcover.txt unicover.txt"
FONT_SUFFIX="ttf"
S=${WORKDIR}/${MY_P}
FONT_S=${S}/ttf

# Only installs fonts
RESTRICT="strip binchecks"

FONT_CONF="$(eval echo "${S}"/fontconfig/{20-unhint-small-dejavu.conf,20-unhint-small-dejavu-experimental.conf,57-dejavu.conf,61-dejavu-experimental.conf})"
