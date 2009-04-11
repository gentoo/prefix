# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/medusa/medusa-0.5.4.ebuild,v 1.16 2008/10/24 11:20:35 armin76 Exp $

inherit distutils

DESCRIPTION="A framework for writing long-running, high-performance network servers in Python, using asynchronous sockets"
HOMEPAGE="http://oedipus.sourceforge.net/medusa/"
## NOTE: for some reason i get 403 to this URL. must mirror on gentoo
SRC_URI="http://www.amk.ca/files/python/${P}.tar.gz"
#SRC_URI="mirror://gentoo/${P}.tar.gz"

IUSE=""
LICENSE="PYTHON"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"

src_install() {
	DOCS="CHANGES.txt docs/*.txt"
	distutils_src_install

	dodir /usr/share/doc/${PF}/example
	cp -r demo/* ${ED}/usr/share/doc/${PF}/example
	dohtml docs/*.html docs/*.gif
}
