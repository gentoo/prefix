# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit eutils

DESCRIPTION="Utility to bootstrap a chained/cross EPREFIX"
HOMEPAGE="http://dev.gentoo.org/~mduft"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86-interix"
IUSE=""

DEPEND="x86-winnt? ( >=sys-devel/parity-1.2.0 )"
RDEPEND=""

pkg_setup() {
	if ! built_with_use 'sys-apps/portage' cross-prefix; then
		eerror "sys-apps/portage was not built with the 'cross-prefix' USE flag"
		eerror "enabled. This makes cross-prefix setups unusable. Please"
		eerror "re-emerge sys-apps/portage with USE=cross-prefix."
		die "sys-apps/portage not cross-prefix-able."
	fi
}

src_install() {
	cp "${FILESDIR}"/cross-prefix-setup.in "${T}"/cross-prefix-setup
	eprefixify "${T}"/cross-prefix-setup

	dobin "${T}"/cross-prefix-setup
}

