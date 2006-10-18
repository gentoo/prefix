# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/gentoolkit/gentoolkit-0.2.3_pre1.ebuild,v 1.1 2006/09/04 05:13:21 fuzzyray Exp $

EAPI="prefix"

inherit eutils python

DESCRIPTION="Collection of administration scripts for Gentoo"
HOMEPAGE="http://www.gentoo.org/proj/en/portage/tools/index.xml"
SRC_URI="mirror://gentoo/${P}.tar.gz http://dev.gentoo.org/~fuzzyray/distfiles/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"

DEPEND=">=sys-apps/portage-2.1.1_pre1
	>=dev-lang/python-2.0
	>=dev-lang/perl-5.6
	>=sys-apps/grep-2.4
	userland_GNU? ( sys-apps/debianutils )"

src_unpack() {
	unpack ${A}
	ebegin "Adjusting to prefix (sloppyly)"
	cd "${S}"
	find . -mindepth 2 -type f | grep -v Makefile | xargs sed -i \
		-e "s|/usr/lib/gentoolkit/pym|${EPREFIX}/usr/lib/gentoolkit/pym|g" \
		-e "s|/usr/lib/portage/pym|${EPREFIX}/usr/lib/portage/pym|g" \
		-e "s|/usr/share/|${EPREFIX}/usr/share/|g" \
		-e "s|^#!/usr/bin/python|#!${EPREFIX}/usr/bin/python|g"
	eend $?
}

src_install() {
	make DESTDIR="${EDEST}/${EPREFIX}" install-gentoolkit || die
}

# Completely remove if no issues found during gentoolkit-0.2.3_pre testing
#pkg_preinst() {
#	# FIXME: Remove from future ebuilds after gentoolkit-0.2.2 is stable
#	rm -f ${PROOT}usr/lib/gentoolkit/pym/gentoolkit.py[co] ${PROOT}usr/lib/gentoolkit/pym/gentoolkit/*.py[co]
#}

pkg_postinst() {
	python_mod_optimize ${PROOT}usr/lib/gentoolkit
	echo
	ewarn "The qpkg and etcat tools are deprecated in favor of equery and"
	ewarn "are no longer installed in ${PROOT}usr/bin in this release."
	ewarn "They are still available in ${PROOT}usr/share/doc/${PF}/deprecated/"
	ewarn "if you *really* want to use them."
	echo
	elog "Another alternative to qpkg and equery are the q applets in"
	elog "app-portage/portage-utils"
	echo
}

pkg_postrm() {
	python_mod_cleanup ${PROOT}usr/lib/gentoolkit
}
