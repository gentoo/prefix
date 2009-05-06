# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xmodmap/xmodmap-1.0.2.ebuild,v 1.12 2009/05/05 08:05:38 fauli Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="utility for modifying keymaps and pointer button mappings in X"

KEYWORDS="~amd64-linux ~x86-linux ~sparc-solaris"
IUSE=""
RDEPEND="x11-libs/libX11"
DEPEND="${RDEPEND}"
