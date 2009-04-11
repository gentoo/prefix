# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/gperf/gperf-3.0.2.ebuild,v 1.3 2008/01/26 14:54:30 swegener Exp $

DESCRIPTION="A perfect hash function generator"
HOMEPAGE="http://www.gnu.org/software/gperf/gperf.html"
SRC_URI="mirror://gnu/gperf/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

src_install() {
	emake DESTDIR="${D}" htmldir="${EPREFIX}"/usr/share/doc/${PF}/html install || die
	dodoc AUTHORS ChangeLog NEWS README
}
