# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-fonts/dejavu/dejavu-2.21.ebuild,v 1.9 2008/01/10 09:52:40 vapier Exp $

inherit font

MY_P=${PN}-ttf-${PV}

DESCRIPTION="DejaVu fonts, bitstream vera with ISO-8859-2 characters"
HOMEPAGE="http://dejavu.sourceforge.net/"
LICENSE="BitstreamVera"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.bz2"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE=""

DOCS="AUTHORS BUGS NEWS README status.txt langcover.txt unicover.txt"
FONT_SUFFIX="ttf"
S=${WORKDIR}/${MY_P}
FONT_S=${S}

# Only installs fonts
RESTRICT="strip binchecks"

FONT_CONF=( "${FILESDIR}/59-dejavu.conf" )
