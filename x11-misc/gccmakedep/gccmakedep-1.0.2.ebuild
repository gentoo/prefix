# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/gccmakedep/gccmakedep-1.0.2.ebuild,v 1.9 2006/10/11 00:30:02 dberkholz Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
# SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="create dependencies in makefiles using 'gcc -M'"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
RDEPEND=""
DEPEND="${RDEPEND}
	x11-proto/xproto"
