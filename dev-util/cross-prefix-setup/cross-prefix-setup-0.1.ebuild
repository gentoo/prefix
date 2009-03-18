# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="prefix 2"

inherit eutils prefix

DESCRIPTION="Utility to bootstrap a chained/cross EPREFIX"
HOMEPAGE="http://dev.gentoo.org/~mduft"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86-interix"
IUSE=""

DEPEND="x86-winnt? ( >=sys-devel/parity-1.2.0 )
	sys-apps/portage[cross-prefix]"
RDEPEND=""

src_install() {
	cp "${FILESDIR}"/cross-prefix-setup.in "${T}"/cross-prefix-setup
	eprefixify "${T}"/cross-prefix-setup

	dobin "${T}"/cross-prefix-setup
}

