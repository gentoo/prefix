# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/ccd2iso/ccd2iso-0.2-r1.ebuild,v 1.4 2007/01/04 22:38:25 drizzt Exp $

WANT_AUTOCONF=latest
WANT_AUTOMAKE=latest
inherit autotools

DESCRIPTION="Converts CloneCD images (popular under Windows) to ISOs"
HOMEPAGE="http://sourceforge.net/projects/ccd2iso/"
SRC_URI="mirror://sourceforge/ccd2iso/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris"
IUSE=""

DEPEND=""

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd "${S}"
	# bundled autotools are all screwed up
	eautoreconf
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS ChangeLog NEWS README TODO
}
