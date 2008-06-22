# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/capistrano-launcher/capistrano-launcher-1.ebuild,v 1.9 2008/06/21 13:27:01 nixnut Exp $

EAPI="prefix"

DESCRIPTION="Launcher script for capistrano"
HOMEPAGE="http://capify.org/"
SRC_URI=""

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE=""

# Block versions of capistrano that install /usr/bin/cap to avoid file-collision
RDEPEND="!~dev-ruby/capistrano-1.99.1
	!~dev-ruby/capistrano-1.99.3
	!<dev-ruby/capistrano-1.4.1-r1
"

src_install() {
	dobin ${FILESDIR}/cap
}

pkg_postinst() {
	einfo "The highest installed version of capistrano will be used when"
	einfo "invoking ${EPREFIX}/usr/bin/cap by default."
	einfo "To invoke a different version, invoke it like:"
	einfo "\tcap _1.4.1_"
}
