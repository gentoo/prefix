# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-base/gnome-mime-data/gnome-mime-data-2.18.0.ebuild,v 1.12 2008/10/12 10:13:17 eva Exp $

inherit gnome2

DESCRIPTION="MIME data for Gnome"
HOMEPAGE="http://www.gnome.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=""
DEPEND=">=dev-util/pkgconfig-0.12.0
		>=dev-util/intltool-0.35"

DOCS="AUTHORS ChangeLog README"

src_unpack() {
	gnome2_src_unpack

	intltoolize --force || die "intltoolize failed"
}
