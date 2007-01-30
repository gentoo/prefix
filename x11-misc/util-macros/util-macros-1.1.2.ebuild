# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/util-macros/util-macros-1.1.2.ebuild,v 1.1 2006/11/10 03:28:31 joshuabaergen Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org autotools utility macros"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
RDEPEND=""
DEPEND="${RDEPEND}"

PATCHES="${FILESDIR}/1.1.1-driver-man-suffix.patch"
