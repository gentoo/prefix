# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/layman/layman-1.1.1.ebuild,v 1.10 2007/11/15 07:16:23 wrobel Exp $

EAPI="prefix"

inherit eutils distutils

DESCRIPTION="A python script for retrieving gentoo overlays."
HOMEPAGE="http://layman.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="test"

DEPEND="test? ( dev-util/subversion )"
RDEPEND=""

pkg_setup() {
	if has_version dev-util/subversion && \
	(! built_with_use --missing true dev-util/subversion webdav || built_with_use --missing false dev-util/subversion nowebdav); then
		eerror "You must rebuild your Subversion with support for WebDAV."
		die "You must rebuild your Subversion with support for WebDAV"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.1.1-prefix.patch
	eprefixify layman/config.py etc/layman.cfg
	find layman/overlays -name "*.py" | xargs sed -i \
		-e '/binary = '"'"'.*'"'"'/s|'"'"'\(.*\)'"'"'|'"'${EPREFIX}"'\1'"'"'|'
}

src_install() {

	distutils_src_install

	dodir /etc/layman
	cp etc/* "${ED}"/etc/layman/

	doman doc/layman.8
	dohtml doc/layman.8.html

}

src_test() {
	cd "${S}"
	einfo "Running layman doctests..."
	echo
	if ! PYTHONPATH="." ${python} layman/tests/dtest.py; then
		eerror "DocTests failed - please submit a bug report"
		die "DocTesting failed!"
	fi
}

pkg_postinst() {
	einfo "You are now ready to add overlays into your system."
	einfo
	einfo "layman -L"
	einfo
	einfo "will display a list of available overlays."
	einfo
	elog  "Select an overlay and add it using"
	einfo
	elog  "layman -a overlay-name"
	einfo
	elog  "If this is the very first overlay you add with layman,"
	elog  "you need to append the following statement to your"
	elog  "${EPREFIX}/etc/make.conf file:"
	elog
	elog  "source ${EPREFIX}/usr/portage/local/layman/make.conf"
	elog
	elog  "If you modify the 'storage' parameter in the layman"
	elog  "configuration file (${EPREFIX}/etc/layman/layman.cfg) you will"
	elog  "need to adapt the path given above to the new storage"
	elog  "directory."
	einfo
	ewarn "Please add the 'source' statement to make.conf only AFTER "
	ewarn "you added your first overlay. Otherwise portage will fail."
	epause 5
}
