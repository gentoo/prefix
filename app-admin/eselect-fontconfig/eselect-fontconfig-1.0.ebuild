# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-fontconfig/eselect-fontconfig-1.0.ebuild,v 1.18 2007/12/29 11:40:34 vapier Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="An eselect module to manage /etc/fonts/conf.d symlinks."
HOMEPAGE="http://www.gentoo.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND="app-admin/eselect
		>=media-libs/fontconfig-2.4"

src_install() {
	cd "${T}"
	cp "${FILESDIR}"/fontconfig.eselect-${PV} .
	epatch "${FILESDIR}"/fontconfig.eselect-${PV}-prefix.patch
	eprefixify fontconfig.eselect-${PV}
	insinto /usr/share/eselect/modules
	newins fontconfig.eselect-${PV} fontconfig.eselect || die
}
