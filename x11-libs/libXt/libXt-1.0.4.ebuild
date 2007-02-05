# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-libs/libXt/libXt-1.0.4.ebuild,v 1.1 2006/11/09 15:51:35 joshuabaergen Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular flag-o-matic

DESCRIPTION="X.Org Xt library"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
RESTRICT="mirror"

RDEPEND="x11-libs/libX11
	x11-libs/libSM
	x11-proto/xproto
	x11-proto/kbproto"
DEPEND="${RDEPEND}"

pkg_setup() {
	# No such function yet
	# x-modular_pkg_setup

	# (#125465) Broken with Bdirect support
	filter-flags -Wl,-Bdirect
	filter-ldflags -Bdirect
	filter-ldflags -Wl,-Bdirect
}
