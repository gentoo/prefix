# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/xproto/xproto-7.0.9.ebuild,v 1.1 2006/11/02 23:02:59 joshuabaergen Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org xproto protocol headers"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
RESTRICT="mirror"

RDEPEND=""
DEPEND="${RDEPEND}"

src_unpack() {
	x-modular_unpack_source
	x-modular_reconf_source
}
