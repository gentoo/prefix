# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/xproto/xproto-7.0.10.ebuild,v 1.6 2007/05/04 20:47:40 dang Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org xproto protocol headers"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"

RDEPEND=""
DEPEND="${RDEPEND}"

src_unpack() {
	x-modular_unpack_source
	x-modular_reconf_source
}
