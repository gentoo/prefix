# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/ico/ico-1.0.2.ebuild,v 1.4 2009/05/05 07:33:42 fauli Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="animate an icosahedron or other polyhedron"
KEYWORDS="~x86-linux ~x86-winnt"
IUSE=""
RDEPEND=">=x11-libs/libX11-0.99.1_pre0"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}"/${P}-winnt.patch
)
