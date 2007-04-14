# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-ruby/ruby-config/ruby-config-0.3.2.ebuild,v 1.4 2007/01/01 16:33:54 grobian Exp $

EAPI="prefix"

inherit eutils multilib

DESCRIPTION="Utility to switch the ruby interpreter beging used"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND="!<dev-ruby/ri-1.8b-r1"
PDEPEND="virtual/ruby"

S=${WORKDIR}

src_unpack() {
	cp ${FILESDIR}/${PN}-0.3.2 .
	epatch "${FILESDIR}"/${PN}-0.3.2-prefix.patch
	eprefixify ${PN}-0.3.2
	sed -i \
		-e "s|@GENTOO_PORTAGE_LIBDIR@|$(get_libdir)|g" \
		-e "s|@GENTOO_PORTAGE_LIBNAME@|$(get_libname)|g" \
		${PN}-0.3.2
}

src_install() {
	newsbin ${PN}-0.3.2 ruby-config || die
}
