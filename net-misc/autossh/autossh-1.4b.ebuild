# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/autossh/autossh-1.4b.ebuild,v 1.1 2008/09/06 01:28:55 gentoofan23 Exp $

DESCRIPTION="Automatically restart SSH sessions and tunnels"
HOMEPAGE="http://www.harding.motd.ca/autossh/"
SRC_URI="http://www.harding.motd.ca/${PN}/${P}.tgz"

LICENSE="BSD"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux"
SLOT="0"
IUSE=""

RDEPEND="net-misc/openssh"

src_install() {
	dobin autossh
	dodoc CHANGES README autossh.host rscreen
	doman autossh.1
}
