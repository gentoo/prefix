# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/bittorrent/bittorrent-5.2.2-r1.ebuild,v 1.1 2011/09/15 07:35:25 ssuominen Exp $

EAPI="3"
PYTHON_DEPEND="2"
PYTHON_USE_WITH="threads"

inherit distutils fdo-mime eutils

MY_P="${P/bittorrent/BitTorrent}"
#MY_P="${MY_P/}"
S=${WORKDIR}/${MY_P}

DESCRIPTION="tool for distributing files via a distributed network of nodes"
HOMEPAGE="http://www.bittorrent.com/"
SRC_URI="http://download.bittorrent.com/dl/archive/${MY_P}.tar.gz"

LICENSE="BitTorrent"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE=""

RDEPEND=">=dev-python/pycrypto-2.0
	>=dev-python/twisted-2
	dev-python/twisted-web
	net-zope/zope-interface"
DEPEND="${RDEPEND}
	app-arch/gzip
	>=sys-apps/sed-4.0.5
	dev-python/dnspython"

DOCS="README.txt TRACKERLESS.txt public.key"
PYTHON_MODNAME="BitTorrent"

src_prepare() {
	# path for documentation is in lowercase #109743
	sed -i -r "s:(dp.*appdir):\1.lower():" BitTorrent/platform.py
	distutils_src_prepare
}

src_install() {
	distutils_src_install
	rm -f "${ED}"/usr/bin/bittorrent

	newinitd "${FILESDIR}"/bittorrent-tracker.initd bittorrent-tracker
	newconfd "${FILESDIR}"/bittorrent-tracker.confd bittorrent-tracker
}

pkg_postinst() {
	einfo "Remember that BitTorrent has changed file naming scheme"
	einfo "To run BitTorrent just execute /usr/bin/bittorrent"
	einfo "To run the init.d, please use /etc/init.d/bittorrent-tracker"
	elog
	elog "If you are upgrading from bittorrent-4.4.0 you must remove "
	elog "the ~/.bittorrent dir to make this version work. Remember to "
	elog "do a backup first!"
	elog
	distutils_pkg_postinst
	fdo-mime_desktop_database_update
}
