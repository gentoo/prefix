# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-proto/fontcacheproto/fontcacheproto-0.1.2.ebuild,v 1.16 2006/08/06 16:42:05 vapier Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org Fontcache protocol headers"

KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
RESTRICT="mirror"

RDEPEND=""
DEPEND="${RDEPEND}"
