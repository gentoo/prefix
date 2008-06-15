# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-mail/offlineimap/offlineimap-6.0.0.ebuild,v 1.1 2008/06/14 19:31:52 dertobi123 Exp $

EAPI="prefix"

inherit distutils

S=${WORKDIR}/${PN}
DESCRIPTION="Powerful IMAP/Maildir synchronization and reader support"
SRC_URI="mirror://debian/pool/main/o/offlineimap/${P/-/_}.tar.gz"
HOMEPAGE="http://software.complete.org/offlineimap"
LICENSE="GPL-2"
IUSE=""
KEYWORDS="~amd64-linux ~x86-linux"
SLOT="0"

DEPEND=""

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
