# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-mail/offlineimap/offlineimap-6.0.3-r1.ebuild,v 1.1 2009/05/16 20:30:24 dertobi123 Exp $

EAPI=2

inherit distutils

S="${WORKDIR}/${PN}"
DESCRIPTION="Powerful IMAP/Maildir synchronization and reader support"
SRC_URI="mirror://debian/pool/main/o/offlineimap/${P/-/_}.tar.gz"
HOMEPAGE="http://software.complete.org/offlineimap"
LICENSE="GPL-2"
IUSE="ssl"
KEYWORDS="~amd64-linux ~x86-linux"
SLOT="0"

DEPEND=""
RDEPEND="dev-lang/python[threads]
	ssl? ( dev-lang/python[ssl] ) "

src_install() {
	distutils_src_install
	dodoc offlineimap.conf offlineimap.conf.minimal offlineimap.sgml
}

pkg_postinst() {
	elog ""
	elog "You will need to configure offlineimap by creating ~/.offlineimaprc"
	elog "Sample configurations are in /usr/share/doc/${P}/"
	elog ""
}
