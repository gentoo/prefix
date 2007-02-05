# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-libs/liblbxutil/liblbxutil-1.0.1.ebuild,v 1.8 2006/09/10 09:11:12 vapier Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org lbxutil library"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"

RDEPEND=""
DEPEND="${RDEPEND}
	x11-proto/xextproto"

append-ldflags -lXdmcp
