# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/bittornado/bittornado-0.3.18-r2.ebuild,v 1.3 2011/03/28 20:31:43 arfrever Exp $

EAPI="3"
PYTHON_DEPEND="2"

inherit distutils eutils

MY_PN="BitTornado"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="TheShad0w's experimental BitTorrent client"
HOMEPAGE="http://www.bittornado.com/"
SRC_URI="http://download2.bittornado.com/download/${MY_P}.tar.gz"
LICENSE="MIT"
SLOT="0"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="gtk"

RDEPEND="gtk? ( =dev-python/wxpython-2.6* )
	dev-python/pycrypto"
DEPEND="${RDEPEND}
	app-arch/unzip
	>=sys-apps/sed-4.0.5"

S="${WORKDIR}/${MY_PN}-CVS"
PIXMAPLOC="/usr/share/pixmaps/bittornado"

pkg_setup() {
	python_set_active_version 2
	python_pkg_setup
}

src_prepare() {
	# fixes wrong icons path
	sed -i "s:os.path.abspath(os.path.dirname(os.path.realpath(sys.argv\[0\]))):\"${PIXMAPLOC}/\":" btdownloadgui.py
	# Needs wxpython-2.6 only, bug #201247
	epatch "${FILESDIR}"/${P}-wxversion.patch

	python_convert_shebangs -r 2 .
}

src_install() {
	distutils_src_install

	if use gtk; then
		dodir ${PIXMAPLOC}
		insinto ${PIXMAPLOC}
		doins icons/*.ico icons/*.gif
	else
		# get rid of any reference to the not-installed gui version
		rm "${ED}"/usr/bin/*gui.py
	fi

	newicon "${FILESDIR}"/favicon.ico ${PN}.ico
	domenu "${FILESDIR}"/bittornado.desktop

	newconfd "${FILESDIR}"/bttrack.conf bttrack
	newinitd "${FILESDIR}"/bttrack.rc bttrack
}
