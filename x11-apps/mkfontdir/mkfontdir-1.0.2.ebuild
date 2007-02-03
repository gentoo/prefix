# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-apps/mkfontdir/mkfontdir-1.0.2.ebuild,v 1.9 2006/10/10 23:55:18 dberkholz Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="create an index of X font files in a directory"

KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"

RDEPEND="x11-apps/mkfontscale"
DEPEND="${RDEPEND}"
