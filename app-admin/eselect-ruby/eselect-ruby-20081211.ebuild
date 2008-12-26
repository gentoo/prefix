# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-ruby/eselect-ruby-20081211.ebuild,v 1.2 2008/12/24 07:50:22 bluebird Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Manages multiple Ruby versions"
HOMEPAGE="http://www.gentoo.org"
SRC_URI="http://dev.a3li.info/gentoo/distfiles/ruby.eselect-${PVR}.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
IUSE=""

RDEPEND=">=app-admin/eselect-1.0.2"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-prefix.patch
	sed -i -e "/^\(bindir\|man1dir\)=/s|=|=\"${EPREFIX}\"|" \
		ruby.eselect-20081211 || die "failed to prefixify"
}

src_install() {
	insinto /usr/share/eselect/modules
	newins "${WORKDIR}/ruby.eselect-${PVR}" ruby.eselect || die
}
