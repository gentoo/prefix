# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xdg-utils/xdg-utils-1.0.2-r1.ebuild,v 1.1 2008/01/26 09:30:33 pva Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Portland utils for cross-platform/cross-toolkit/cross-desktop interoperability"
HOMEPAGE="http://portland.freedesktop.org/wiki/Portland"
SRC_URI="http://portland.freedesktop.org/download/${P}.tgz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86-fbsd ~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~x86-macos"
IUSE="doc"

RESTRICT="test"

RDEPEND="x11-apps/xprop"
DEPEND="app-shells/bash"

src_unpack() {
	unpack ${A}
	cd "${S}"/scripts

	epatch "${FILESDIR}"/${P}-arb-comm-exec.patch
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc ChangeLog README RELEASE_NOTES TODO
	newdoc scripts/README README.scripts
	use doc && dohtml -r scripts/html
}
