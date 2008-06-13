# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xlsfonts/xlsfonts-1.0.2.ebuild,v 1.11 2007/08/08 12:35:08 gustavoz Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="X.Org xlsfonts application"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"

RDEPEND="x11-libs/libX11"
DEPEND="${RDEPEND}"
