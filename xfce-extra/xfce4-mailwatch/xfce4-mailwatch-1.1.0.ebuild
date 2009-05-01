# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/xfce-extra/xfce4-mailwatch/xfce4-mailwatch-1.1.0.ebuild,v 1.8 2009/05/01 04:31:13 darkside Exp $

inherit xfce44 eutils

xfce44
xfce44_plugin

DESCRIPTION="Mail notification panel plugin"
HOMEPAGE="http://spuriousinterrupt.org/projects/mailwatch"
SRC_URI="http://spuriousinterrupt.org/files/mailwatch/${MY_P}.tar.bz2"

KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE="ssl"

RDEPEND="ssl? ( >=net-libs/gnutls-1.2 )"
DEPEND="dev-util/intltool"

xfce44_panel_plugin

pkg_setup() {
	XFCE_CONFIG="${XFCE_CONFIG} $(use_enable ssl)"
}

src_unpack()
{
	unpack ${A}
	cd "${S}"

	# http://bugzilla.xfce.org/show_bug.cgi?id=4608
	epatch "${FILESDIR}/${P}-no-ssl.patch"
}
