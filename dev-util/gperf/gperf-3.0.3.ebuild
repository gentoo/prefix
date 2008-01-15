# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/gperf/gperf-3.0.3.ebuild,v 1.3 2008/01/14 20:17:13 dertobi123 Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="A perfect hash function generator"
HOMEPAGE="http://www.gnu.org/software/gperf/gperf.html"
SRC_URI="mirror://gnu/gperf/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

src_install() {
	make DESTDIR="${D}" install || die
}
