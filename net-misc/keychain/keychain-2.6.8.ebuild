# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/keychain/keychain-2.6.8.ebuild,v 1.3 2007/09/15 02:30:13 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="ssh-agent manager"
HOMEPAGE="http://www.gentoo.org/proj/en/keychain/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-aix ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
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
