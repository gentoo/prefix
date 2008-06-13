# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xmodmap/xmodmap-1.0.3.ebuild,v 1.6 2008/02/05 11:36:37 corsair Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="utility for modifying keymaps and pointer button mappings in X"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~sparc-solaris"

RDEPEND="x11-libs/libX11"
DEPEND="${RDEPEND}"
