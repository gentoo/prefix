# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/bittorrent/bittorrent-4.4.0.ebuild,v 1.12 2006/09/30 18:55:20 vapier Exp $

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
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="aqua gtk"

RDEPEND="gtk? (
		>=x11-libs/gtk+-2.6
		>=dev-python/pygtk-2.6
	)
	>=dev-lang/python-2.3
	>=dev-python/pycrypto-2.0
	!virtual/bittorrent"
DEPEND="${RDEPEND}
	app-arch/gzip
	>=sys-apps/sed-4.0.5
	dev-python/dnspython"
PROVIDE="virtual/bittorrent"

DOCS="TRACKERLESS.txt LICENSE.txt public.key"
PYTHON_MODNAME="BitTorrent"

src_unpack() {
	unpack ${A}
	cd ${S}

	# path for documentation is in lowercase (see bug #109743)
	sed -i -r "s:(dp.*appdir):\1.lower():" BitTorrent/platform.py
}

src_install() {
	distutils_src_install
	if ! use gtk || ! use aqua; then
		rm ${D}/usr/bin/bittorrent
	fi
	dohtml redirdonate.html

	mv ${S}/{credits-l10n.txt,credits.txt} \
		${D}/usr/share/doc/${P}

	if use gtk ; then
		cp ${D}/usr/share/pixmaps/${MY_P}/bittorrent.ico ${D}/usr/share/pixmaps/
		make_desktop_entry "bittorrent" "BitTorrent" \
			/usr/share/pixmaps/bittorrent.ico "Network"
		echo "MimeType=application/x-bittorrent" \
			>> ${D}/usr/share/applications/bittorrent-${PN}.desktop
	fi

	insinto /etc/conf.d
	newins ${FILESDIR}/bttrack.conf bttrack

	exeinto /etc/init.d
	newexe ${FILESDIR}/bttrack.rc bttrack
}

pkg_postinst() {
	einfo "Remember that BitTorrent has changed file naming scheme"
	einfo "To run BitTorrent just execute /usr/bin/bittorrent"
	distutils_pkg_postinst
	fdo-mime_desktop_database_update
}
