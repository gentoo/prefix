# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Pango/Pango-1.220.ebuild,v 1.1 2009/06/07 18:16:27 tove Exp $

EAPI=2

MODULE_AUTHOR=TSCH
inherit perl-module

DESCRIPTION="Layout and render international text"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=dev-perl/glib-perl-1.220
	>=dev-perl/Cairo-1.00
	>=x11-libs/pango-1.0.0"
DEPEND=">=dev-perl/extutils-depends-0.300
	>=dev-perl/extutils-pkgconfig-1.030
	${RDEPEND}"
