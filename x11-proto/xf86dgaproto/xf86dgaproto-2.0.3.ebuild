# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-proto/xf86dgaproto/xf86dgaproto-2.0.3.ebuild,v 1.6 2008/02/05 11:47:02 corsair Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org XF86DGA protocol headers"

KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"

RDEPEND=""
DEPEND="${RDEPEND}"
