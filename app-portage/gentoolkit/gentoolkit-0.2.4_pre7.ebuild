# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/gentoolkit/gentoolkit-0.2.4_pre7.ebuild,v 1.2 2007/11/03 16:47:20 grobian Exp $

EAPI="prefix"

inherit eutils python

DESCRIPTION="Collection of administration scripts for Gentoo"
HOMEPAGE="http://www.gentoo.org/proj/en/portage/tools/index.xml"
SRC_URI="mirror://gentoo/${P}.tar.gz http://dev.gentoo.org/~fuzzyray/distfiles/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
IUSE="userland_GNU"

KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

DEPEND=">=sys-apps/portage-2.1.1_pre1
	>=dev-lang/python-2.0
	>=dev-lang/perl-5.6
	>=sys-apps/grep-2.4
	userland_GNU? ( sys-apps/debianutils )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.2.4_pre7-revdep-prefix.patch
	epatch "${FILESDIR}"/${PN}-0.2.4_pre7-revdep-darwin.patch
	epatch "${FILESDIR}"/${PN}-0.2.4_pre7-revdep-interix.patch
	epatch "${FILESDIR}"/${PN}-0.2.4_pre7-revdep-aix.patch
	epatch "${FILESDIR}"/${PN}-0.2.4_pre7-revdep-sunos.patch
	epatch "${FILESDIR}"/${PN}-0.2.4_pre6-deprecate.patch
	ebegin "Adjusting to prefix (sloppyly)"
	find . -mindepth 2 -type f | grep -v Makefile | xargs sed -i \
		-e "s|/usr/lib/gentoolkit/pym|${EPREFIX}/usr/lib/gentoolkit/pym|g" \
		-e "s|/usr/lib/portage/pym|${EPREFIX}/usr/lib/portage/pym|g" \
		-e "s|/usr/share/|${EPREFIX}/usr/share/|g" \
		-e "s|^#!/usr/bin/python|#!${EPREFIX}/usr/bin/python|g" \
		-e "s|^#!/bin/bash|#!${EPREFIX}/bin/bash|g" \
		-e "s|=/etc|=${EPREFIX}/etc|g"
	eend $?
	eprefixify src/revdep-rebuild/99revdep-rebuild
}

src_install() {
	make DESTDIR="${D}${EPREFIX}" install-gentoolkit || die
}

pkg_postinst() {
	python_mod_optimize ${EROOT}usr/lib/gentoolkit
	echo
	ewarn "This version of gentoolkit contains a rewritten version of"
	ewarn "revdep-rebuild. If you encounter issues with the new version,"
	ewarn "The previous version can be found at:"
	ewarn "${EPREFIX}/usr/lib/gentoolkit/bin/revdep-rebuild"
	ewarn
	elog "Another alternative to equery is app-portage/portage-utils"
	elog
	elog "For further information on gentoolkit, please read the gentoolkit"
	elog "guide: http://www.gentoo.org/doc/en/gentoolkit.xml"
	elog
}

pkg_postrm() {
	python_mod_cleanup ${EROOT}usr/lib/gentoolkit
}
