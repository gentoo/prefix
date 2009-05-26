# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/layman/layman-1.2.3.ebuild,v 1.10 2009/05/24 22:09:25 jer Exp $

EAPI=2

inherit eutils distutils prefix

DESCRIPTION="A python script for retrieving gentoo overlays."
HOMEPAGE="http://layman.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="git subversion test"

DEPEND="dev-python/pyxml
	test? ( dev-util/subversion )"
RDEPEND=">=dev-lang/python-2.5
	git? ( dev-util/git )
	subversion? (
		|| (
			>=dev-util/subversion-1.5.4[webdav-neon]
			>=dev-util/subversion-1.5.4[webdav-serf]
		)
	)"

pkg_setup() {
	if ! has_version dev-util/subversion; then
		ewarn "You do not have dev-util/subversion installed!"
		ewarn "While layman does not exactly depend on this"
		ewarn "version control system you should note that"
		ewarn "most available overlays are offered via"
		ewarn "dev-util/subversion. If you do not install it"
		ewarn "you will be unable to use these overlays."
		ewarn
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.2.0-prefix.patch
	eprefixify layman/config.py etc/layman.cfg
	find layman/overlays -name "*.py" | xargs sed -i \
		-e '/binary\(_command \)\? = '"'"'.*'"'"'/s|'"'"'\(.*\)'"'"'|'"'${EPREFIX}"'\1'"'"'|'
}

src_install() {

	distutils_src_install

	dodir /etc/layman

	cp etc/* "${ED}"/etc/layman/

	doman doc/layman.8
	dohtml doc/layman.8.html

	keepdir /usr/local/portage/layman
}

src_test() {
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
	elog  "source ${EPREFIX}/usr/local/portage/layman/make.conf"
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
