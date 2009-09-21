# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-apps/scgi/scgi-1.13.ebuild,v 1.1 2009/09/17 09:02:45 hollow Exp $

inherit distutils

DESCRIPTION="Replacement for the CGI protocol that is similar to FastCGI."
HOMEPAGE="http://www.mems-exchange.org/software/scgi/"
SRC_URI="http://python.ca/scgi/releases/${P}.tar.gz"

LICENSE="CNRI"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

pkg_postinst() {
	distutils_pkg_postinst
	einfo "This package does not install mod_scgi!"
	einfo "Please 'emerge mod_scgi' if you need it."
}
