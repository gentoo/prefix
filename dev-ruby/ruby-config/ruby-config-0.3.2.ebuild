# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ruby-config/ruby-config-0.3.2.ebuild,v 1.2 2006/03/31 21:02:42 flameeyes Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Utility to switch the ruby interpreter beging used"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

RDEPEND="!<dev-ruby/ri-1.8b-r1"
PDEPEND="virtual/ruby"

S=${WORKDIR}

src_unpack() {
	cp ${FILESDIR}/${PN}-0.3.2 .
	epatch "${FILESDIR}"/${PN}-0.3.2-prefix.patch
	einfo "Adjusting to prefix"
	sed -i \
		-e "s|@GENTOO_PORTAGE_EPREFIX@|${EPREFIX}|g" \
		${PN}-0.3.2
	eend $?
}

src_install() {
	newsbin ${PN}-0.3.2 ruby-config || die
}
