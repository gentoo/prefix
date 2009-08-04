# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/keychain/keychain-2.6.9.ebuild,v 1.1 2009/08/02 03:47:09 darkside Exp $

EAPI="2"

DESCRIPTION="manage ssh and GPG keys in a convenient and secure manner. Frontend
for ssh-agent/ssh-add"
HOMEPAGE="http://www.funtoo.org/en/security/keychain/intro/"
SRC_URI="http://www.funtoo.org/archive/keychain/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}
	app-shells/bash
	|| ( net-misc/openssh net-misc/ssh )"

src_install() {
	dobin keychain || die "dobin failed"
	doman keychain.1 || die "doman failed"
	dodoc ChangeLog README.rst || die
}

src_test() {
	# Work in progress, not all pass so we don't die yet.
	./runtests
}

pkg_postinst() {
	einfo "Please see the Keychain Guide at"
	einfo "http://www.gentoo.org/doc/en/keychain-guide.xml"
	einfo "for help getting keychain running"
	einfo "Note for Prefix users: keychain doesn't use Prefix paths and tools,"
	einfo "because it is highly tuned to use the original OS supplied tools and"
	einfo "doesn't expect otherwise (e.g. it actually breaks with Prefix tools)"
}
