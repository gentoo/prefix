# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/crossdev/crossdev-0.9.18-r10.ebuild,v 1.3 2008/12/10 04:23:05 vapier Exp $

DESCRIPTION="Gentoo Cross-toolchain generator"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

RDEPEND=">=sys-apps/portage-2.1
	app-shells/bash
	|| ( dev-util/unifdef sys-freebsd/freebsd-ubin >=sys-apps/darwin-miscutils-4 )"

src_install() {
	newsbin "${FILESDIR}"/crossdev-stable crossdev || die
	dosed "s:GENTOO_PV:${PV}:" /usr/sbin/crossdev
}
