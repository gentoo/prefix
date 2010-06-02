# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/gentoolkit/gentoolkit-0.3.0_rc10-r1.ebuild,v 1.2 2010/04/27 10:15:18 aballier Exp $

EAPI="2"
SUPPORT_PYTHON_ABIS="1"
DISTUTILS_DISABLE_VERSIONING_OF_PYTHON_SCRIPTS="1"
RESTRICT_PYTHON_ABIS="2.[45]"

inherit distutils python eutils

DESCRIPTION="Collection of administration scripts for Gentoo"
HOMEPAGE="http://www.gentoo.org/proj/en/portage/tools/index.xml"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

# Drop ~sparc-fbsd ~x86-fbsd due to app-misc/realpath dependency
KEYWORDS="~ppc-aix ~x64-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

DEPEND="sys-apps/portage
	>=dev-lang/python-2.6[xml]
	!!>=dev-lang/python-2.6[-xml]"
RDEPEND="${DEPEND}
	|| ( app-misc/realpath sys-freebsd/freebsd-bin )
	sys-apps/gawk
	sys-apps/grep"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-0.3.0_rc9-revdep-prefix.patch
#	epatch "${FILESDIR}"/${PN}-0.3.0_rc7-eclean-prefix.patch
	epatch "${FILESDIR}"/${PN}-0.3.0_rc8-setup-prefix.patch

	ebegin "Adjusting to prefix (sloppyly)"
	find . -mindepth 2 -type f | grep -v Makefile | xargs sed -i \
		-e "s|/usr/lib/gentoolkit/pym|${EPREFIX}/usr/lib/gentoolkit/pym|g" \
		-e "s|/usr/lib/portage/pym|${EPREFIX}/usr/lib/portage/pym|g" \
		-e "s|/usr/share/|${EPREFIX}/usr/share/|g" \
		-e "s|^#!/usr/bin/python|#!${EPREFIX}/usr/bin/python|g" \
		-e "s|^#!/bin/bash|#!${EPREFIX}/bin/bash|g" \
		-e "s|=/etc|=${EPREFIX}/etc|g"
	eend $?
	eprefixify data/revdep-rebuild/99revdep-rebuild bin/revdep-rebuild bin/eclean setup.py
	epatch "${FILESDIR}/eclean.313901.patch"
}

distutils_src_compile_pre_hook() {
	echo VERSION="${PVR}" "$(PYTHON)" setup.py set_version
	VERSION="${PVR}" "$(PYTHON)" setup.py set_version
}

src_install() {
	python_convert_shebangs -r "" build-*/scripts-*
	distutils_src_install

	# Create cache directory for revdep-rebuild
	dodir /var/cache/revdep-rebuild
	keepdir /var/cache/revdep-rebuild
	use prefix || fowners root:root /var/cache/revdep-rebuild
	fperms 0700 /var/cache/revdep-rebuild

	# remove on platforms where it's broken anyway
	[[ ${CHOST} != *-aix* ]] && rm "${ED}"/usr/bin/revdep-rebuild

	# Can distutils handle this?
	dosym eclean /usr/bin/eclean-dist
	dosym eclean /usr/bin/eclean-pkg
}

pkg_postinst() {
	distutils_pkg_postinst

	# Make sure that our ownership and permissions stuck
	use prefix || chown root:root "${EROOT}/var/cache/revdep-rebuild"
	chmod 0700 "${EROOT}/var/cache/revdep-rebuild"

	einfo
	einfo "For further information on gentoolkit, please read the gentoolkit"
	einfo "guide: http://www.gentoo.org/doc/en/gentoolkit.xml"
	einfo
	einfo "Another alternative to equery is app-portage/portage-utils"
}
