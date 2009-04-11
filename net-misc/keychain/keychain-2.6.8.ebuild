# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/keychain/keychain-2.6.8.ebuild,v 1.9 2008/03/02 13:15:50 philantrop Exp $

inherit eutils

DESCRIPTION="ssh-agent manager"
HOMEPAGE="http://www.gentoo.org/proj/en/keychain/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	app-shells/bash
	|| ( net-misc/openssh net-misc/ssh )"

src_install() {
	dobin keychain || die "dobin failed"
	doman keychain.1 || die "doman failed"
	dodoc ChangeLog keychain.pod README
}

pkg_postinst() {
	einfo "Please see the Keychain Guide at"
	einfo "http://www.gentoo.org/doc/en/keychain-guide.xml"
	einfo "for help getting keychain running"
	einfo "Note for prefix users: keychain doesn't use prefix paths and stuff,"
	einfo "because it is highly tuned to use the original OS supplied tools."
}
