# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/httrack/httrack-3.43.1.ebuild,v 1.2 2009/03/06 18:27:52 drizzt Exp $

inherit versionator

MY_P="${PN}-$(get_version_component_range 1-2)"
DESCRIPTION="HTTrack Website Copier, Open Source Offline Browser"
HOMEPAGE="http://www.httrack.com/"
SRC_URI="http://www.httrack.com/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

src_compile() {
	econf || die
	# won't compile in parallel
	emake -j1 || die
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS README greetings.txt history.txt
	dohtml httrack-doc.html
}
