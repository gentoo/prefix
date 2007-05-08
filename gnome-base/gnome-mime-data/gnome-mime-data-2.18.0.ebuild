# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-mime-data/gnome-mime-data-2.18.0.ebuild,v 1.2 2007/04/24 13:48:12 uberlord Exp $

EAPI="prefix"

inherit gnome2

DESCRIPTION="MIME data for Gnome"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~x86"
IUSE=""

DEPEND=">=dev-util/pkgconfig-0.12.0
		>=dev-util/intltool-0.35"
RDEPEND=""

DOCS="AUTHORS ChangeLog README"
