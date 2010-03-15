# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/webapp-config/webapp-config-1.50.16-r3.ebuild,v 1.3 2010/03/10 03:16:31 sping Exp $

inherit eutils distutils prefix

DESCRIPTION="Gentoo's installer for web-based applications"
HOMEPAGE="http://sourceforge.net/projects/webapp-config/"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-apache-move.patch
	epatch "${FILESDIR}"/${P}-baselayout2.patch
	epatch "${FILESDIR}"/${P}-htdocs-symlink.patch
	epatch "${FILESDIR}"/${P}-absolute-paths.patch
	epatch "${FILESDIR}"/${P}-prefix.patch

	eprefixify \
		WebappConfig/config.py \
		WebappConfig/db.py \
		WebappConfig/sandbox.py \
		WebappConfig/wrapper.py \
		sbin/webapp-cleaner \
		config/webapp-config

	rm -f doc/webapp.eclass.5{,.html}
}

src_install() {
	# According to this discussion:
	# http://mail.python.org/pipermail/distutils-sig/2004-February/003713.html
	# distutils does not provide for specifying two different script install
	# locations. Since we only install one script here the following should
	# be ok
	distutils_src_install --install-scripts="${EPREFIX}/usr/sbin"

	insinto /etc/vhosts
	doins config/webapp-config

	keepdir /usr/share/webapps
	keepdir /var/db/webapps

	dodoc examples/phpmyadmin-2.5.4-r1.ebuild AUTHORS.txt CHANGES.txt examples/postinstall-en.txt
	doman doc/*.[58]
	dohtml doc/*.[58].html
}

src_test() {
	distutils_python_version
	if [[ $PYVER_MAJOR -gt 1 ]] && [[ $PYVER_MINOR -gt 3 ]] ; then
		elog "Running webapp-config doctests..."
		if ! PYTHONPATH="." ${python} WebappConfig/tests/dtest.py; then
			eerror "DocTests failed - please submit a bug report"
			die "DocTesting failed!"
		fi
	else
		elog "Python version below 2.4! Disabling tests."
	fi
}

pkg_postinst() {
	echo
	elog "Now that you have upgraded webapp-config, you **must** update your"
	elog "config files in /etc/vhosts/webapp-config before you emerge any"
	elog "packages that use webapp-config."
	echo
	epause 5
}
