# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/bittorrent/bittorrent-4.4.0.ebuild,v 1.13 2006/12/28 19:00:17 vapier Exp $

EAPI="prefix"

inherit distutils fdo-mime eutils

MY_P="${P/bittorrent/BitTorrent}"
#MY_P="${MY_P/}"
S=${WORKDIR}/${MY_P}

DESCRIPTION="tool for distributing files via a distributed network of nodes"
HOMEPAGE="http://www.bittorrent.com/"
SRC_URI="http://www.bittorrent.com/dl/${MY_P}.tar.gz"

LICENSE="BitTorrent"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-solaris"
IUSE="aqua gtk"

RDEPEND=">=dev-lang/python-2.3
	gtk? (
		>=x11-libs/gtk+-2.6
		>=dev-python/pygtk-2.6
	)
	>=dev-python/pycrypto-2.0
	!virtual/bittorrent"
DEPEND="${RDEPEND}
	app-arch/gzip
	>=sys-apps/sed-4.0.5
	dev-python/dnspython"
PROVIDE="virtual/bittorrent"

DOCS="TRACKERLESS.txt public.key credits.txt"
PYTHON_MODNAME="BitTorrent"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# path for documentation is in lowercase #109743
	sed -i -r "s:(dp.*appdir):\1.lower():" BitTorrent/platform.py
}

src_install() {
	distutils_src_install
	use gtk || use aqua || rm -f "${ED}"/usr/bin/bittorrent
	dohtml redirdonate.html

	if use gtk ; then
		doicon images/logo/bittorrent.ico
		make_desktop_entry "bittorrent" "BitTorrent" bittorrent.ico "Network"
		echo "MimeType=application/x-bittorrent" \
			>> "${ED}"/usr/share/applications/bittorrent-${PN}.desktop
	fi

	newinitd "${FILESDIR}"/bittorrent-tracker.initd bittorrent-tracker
	newconfd "${FILESDIR}"/bittorrent-tracker.confd bittorrent-tracker
}

pkg_postinst() {
	einfo "Remember that BitTorrent has changed file naming scheme"
	einfo "To run BitTorrent just execute /usr/bin/bittorrent"
	einfo "To run the init.d, please use /etc/init.d/bittorrent-tracker"
	distutils_pkg_postinst
	fdo-mime_desktop_database_update
}
