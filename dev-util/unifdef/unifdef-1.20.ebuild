# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/unifdef/unifdef-1.20.ebuild,v 1.4 2007/05/23 16:29:47 flameeyes Exp $

DESCRIPTION="remove #ifdef'ed lines from a file while otherwise leaving the file alone"
HOMEPAGE="http://freshmeat.net/projects/unifdef/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

DEPEND=""

S=${WORKDIR}/${P}/Debian

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc ../README.Gentoo README
}
