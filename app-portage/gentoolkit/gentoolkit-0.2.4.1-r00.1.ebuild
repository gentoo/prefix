# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/gentoolkit/gentoolkit-0.2.4.1.ebuild,v 1.1 2008/09/04 03:35:22 fuzzyray Exp $

EAPI="prefix"

inherit eutils python

DESCRIPTION="Collection of administration scripts for Gentoo"
HOMEPAGE="http://www.gentoo.org/proj/en/portage/tools/index.xml"
SRC_URI="mirror://gentoo/${P}.tar.gz http://dev.gentoo.org/~fuzzyray/distfiles/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
IUSE="userland_GNU"

KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

DEPEND=">=sys-apps/portage-2.1.1_pre1
	>=dev-lang/python-2.0
	>=dev-lang/perl-5.6
	>=sys-apps/grep-2.4
	userland_GNU? ( sys-apps/debianutils )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-revdep-prefix.patch
	epatch "${FILESDIR}"/${P}-eclean-prefix.patch
	# revdep-rebuild got a rewrite, none of our patches still works :(

	ebegin "Adjusting to prefix (sloppyly)"
	find . -mindepth 2 -type f | grep -v Makefile | xargs sed -i \
		-e "s|/usr/lib/gentoolkit/pym|${EPREFIX}/usr/lib/gentoolkit/pym|g" \
		-e "s|/usr/lib/portage/pym|${EPREFIX}/usr/lib/portage/pym|g" \
		-e "s|/usr/share/|${EPREFIX}/usr/share/|g" \
		-e "s|^#!/usr/bin/python|#!${EPREFIX}/usr/bin/python|g" \
		-e "s|^#!/bin/bash|#!${EPREFIX}/bin/bash|g" \
		-e "s|=/etc|=${EPREFIX}/etc|g"
	eend $?
	eprefixify src/revdep-rebuild/{99,}revdep-rebuild
}

src_install() {
	emake DESTDIR="${D}/${EPREFIX}" install-gentoolkit || die "install-gentoolkit failed"

	# Create cache directory for revdep-rebuild
	dodir /var/cache/revdep-rebuild
	keepdir /var/cache/revdep-rebuild
	use prefix || fowners root:root /var/cache/revdep-rebuild
	fperms 0700 /var/cache/revdep-rebuild

	# remove on platforms where it's broken anyway
	[[ ${CHOST} != *-aix* ]] && rm "${ED}"/usr/bin/revdep-rebuild
}

pkg_postinst() {
	# Make sure that our ownership and permissions stuck
	use prefix || chown root:root "${EROOT}/var/cache/revdep-rebuild"
	chmod 0700 "${EROOT}/var/cache/revdep-rebuild"

	python_mod_optimize /usr/lib/gentoolkit
	echo
	elog "The default location for revdep-rebuild files has been moved"
	elog "to /var/cache/revdep-rebuild when run as root."
	elog
	elog "Another alternative to equery is app-portage/portage-utils"
	elog
	elog "For further information on gentoolkit, please read the gentoolkit"
	elog "guide: http://www.gentoo.org/doc/en/gentoolkit.xml"
}

pkg_postrm() {
	python_mod_cleanup /usr/lib/gentoolkit
}
