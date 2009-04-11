# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/appres/appres-1.0.1.ebuild,v 1.12 2007/08/07 13:21:25 gustavoz Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="list X application resource database"

KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x64-solaris ~x86-solaris ~x86-winnt"

RDEPEND="x11-libs/libX11
	x11-libs/libXt"
DEPEND="${RDEPEND}"
