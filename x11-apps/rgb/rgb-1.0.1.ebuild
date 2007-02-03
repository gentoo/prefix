# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-apps/rgb/rgb-1.0.1.ebuild,v 1.11 2006/12/19 23:54:19 dberkholz Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="uncompile an rgb color-name database"

KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"

RDEPEND=""
DEPEND="${RDEPEND}
	x11-proto/xproto"
