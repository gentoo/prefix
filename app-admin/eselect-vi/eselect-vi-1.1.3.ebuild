# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-vi/eselect-vi-1.1.3.ebuild,v 1.7 2006/10/24 23:46:03 spb Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Manages the /usr/bin/vi symlink."
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/vi.eselect-${PVR}.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-macos ~x86"
IUSE=""

RDEPEND=">=app-admin/eselect-1.0.6"

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}"/${P}-prefix.patch

	eprefixify vi.eselect-1.1.3
}

src_install() {
	insinto /usr/share/eselect/modules
	newins "${WORKDIR}/vi.eselect-${PVR}" vi.eselect
}
