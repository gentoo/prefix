# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/keychain/keychain-2.6.6.ebuild,v 1.4 2006/12/02 15:56:51 flameeyes Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="ssh-agent manager"
HOMEPAGE="http://www.gentoo.org/proj/en/keychain/"
SRC_URI="http://dev.gentoo.org/~agriffis/keychain/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	app-shells/bash
	|| ( net-misc/openssh net-misc/ssh )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-prefix.patch
	ebegin "Adjusting to prefix"
	sed -i \
		-e "s|@GENTOO_PORTAGE_EPREFIX@|${EPREFIX}|g" \
		keychain
	eend $?
}

src_install() {
	dobin keychain || die "dobin failed"
	dodoc ChangeLog keychain.pod README
	doman keychain.1 || die "doman failed"
}

pkg_postinst() {
	echo
	einfo "Please see the Keychain Guide at"
	einfo "http://www.gentoo.org/doc/en/keychain-guide.xml"
	einfo "for help getting keychain running"
	echo
}
