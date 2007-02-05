# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-proto/xcmiscproto/xcmiscproto-1.1.2.ebuild,v 1.15 2006/08/06 16:47:23 vapier Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org XCMisc protocol headers"

KEYWORDS="~amd64 ~ia64 ppc-macos ~x86 ~x86-macos"
RESTRICT="mirror"

RDEPEND=""
DEPEND="${RDEPEND}"
