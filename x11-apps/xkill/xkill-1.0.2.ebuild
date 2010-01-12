# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xkill/xkill-1.0.2.ebuild,v 1.5 2009/12/27 17:48:43 josejx Exp $

inherit x-modular

DESCRIPTION="kill a client by its X resource"

KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-winnt"
IUSE=""

RDEPEND="x11-libs/libX11
	x11-libs/libXmu"
DEPEND="${RDEPEND}"
