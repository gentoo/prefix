# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-mime-data/gnome-mime-data-2.18.0.ebuild,v 1.11 2007/09/22 05:21:47 tgall Exp $

EAPI="prefix"

inherit gnome2

DESCRIPTION="MIME data for Gnome"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~sparc-solaris"
IUSE=""

DEPEND=">=dev-util/pkgconfig-0.12.0
		>=dev-util/intltool-0.35"
RDEPEND=""

DOCS="AUTHORS ChangeLog README"
