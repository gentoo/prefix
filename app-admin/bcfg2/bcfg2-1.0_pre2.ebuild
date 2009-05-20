# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/bcfg2/bcfg2-1.0_pre2.ebuild,v 1.1 2009/05/20 02:42:34 darkside Exp $

inherit distutils

DESCRIPTION="Bcfg2 is a configuration management tool."
HOMEPAGE="http://trac.mcs.anl.gov/projects/bcfg2"

# handle the "pre" case
MY_P="${P/_/}"
SRC_URI="ftp://ftp.mcs.anl.gov/pub/bcfg/${MY_P}.tar.gz"
S="${WORKDIR}/${MY_P}"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x64-solaris"
IUSE="server"

DEPEND=">=dev-lang/python-2.5
	dev-python/m2crypto"

RDEPEND="app-portage/gentoolkit
	dev-python/lxml
	server? (
		dev-python/lxml
		dev-python/pyopenssl
		app-admin/gam-server )"

src_install() {
	distutils_src_install --record=PY_SERVER_LIBS --install-scripts "${EPREFIX}"/usr/sbin

	# Remove files only necessary for a server installation
	if ! use server; then
		rm -rf "${ED}"/usr/sbin/bcfg2-*
		rm -rf "${ED}"/usr/share/bcfg2
		rm -rf "${ED}"/usr/share/man/man8
	fi

	# Install a server init.d script
	if use server; then
		newinitd "${FILESDIR}"/bcfg2-server.rc bcfg2-server
	fi

	insinto /etc
	doins "${S}"/examples/bcfg2.conf
}

pkg_postinst () {
	depscan.sh
	use server && einfo "If this is a new installation, you probably need to run: "
	use server && einfo "    bcfg2-admin init"
}

pkg_postrm () {
	depscan.sh
}
