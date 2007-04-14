# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/gentoolkit/gentoolkit-0.2.4_pre4.ebuild,v 1.1 2007/04/11 05:03:10 fuzzyray Exp $

EAPI="prefix"

inherit eutils python

DESCRIPTION="Collection of administration scripts for Gentoo"
HOMEPAGE="http://www.gentoo.org/proj/en/portage/tools/index.xml"
SRC_URI="mirror://gentoo/${P}.tar.gz http://dev.gentoo.org/~fuzzyray/distfiles/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"

DEPEND=">=sys-apps/portage-2.1.1_pre1
	>=dev-lang/python-2.0
	>=dev-lang/perl-5.6
	>=sys-apps/grep-2.4
	userland_GNU? ( sys-apps/debianutils )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-0.2.4-revdep-prefix-darwin.patch
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
	make DESTDIR="${D}/${EPREFIX}" install-gentoolkit || die
}

pkg_postinst() {
	python_mod_optimize ${EROOT}usr/lib/gentoolkit
	echo
	ewarn "The qpkg and etcat tools are deprecated in favor of equery and"
	ewarn "are no longer installed in ${EROOT}usr/bin in this release."
	ewarn "They are still available in ${EROOT}usr/share/doc/${PF}/deprecated/"
	ewarn "if you *really* want to use them."
	elog
	elog "Another alternative to qpkg and equery are the q applets in"
	elog "app-portage/portage-utils"
	elog
	elog "For further information on gentoolkit, please read the gentoolkit"
	elog "guide: http://www.gentoo.org/doc/en/gentoolkit.xml"
	elog
}

pkg_postrm() {
	python_mod_cleanup ${EROOT}usr/lib/gentoolkit
}
