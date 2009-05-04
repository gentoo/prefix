# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-apps/scgi/scgi-1.12.ebuild,v 1.1 2008/04/28 12:03:57 chtekk Exp $

inherit distutils

KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

DESCRIPTION="Replacement for the CGI protocol that is similar to FastCGI."
HOMEPAGE="http://www.mems-exchange.org/software/scgi/"
SRC_URI="http://www.mems-exchange.org/software/files/${PN}/${P}.tar.gz"

LICENSE="CNRI"
SLOT="0"
IUSE=""

pkg_postinst() {
	distutils_pkg_postinst
	einfo "This package does not install mod_scgi!"
	einfo "Please 'emerge mod_scgi' if you need it."
}
