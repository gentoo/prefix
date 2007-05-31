# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/icon-naming-utils/icon-naming-utils-0.8.2.ebuild,v 1.9 2007/05/28 09:29:58 jer Exp $

EAPI="prefix"

DESCRIPTION="Utilities to help with the transition to the new freedesktop.org naming scheme, they will map the new names to the legacy names used by the GNOME and KDE desktops"
HOMEPAGE="http://tango-project.org/"
SRC_URI="http://tango-project.org/releases/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~x86"
IUSE=""

RDEPEND=">=dev-perl/XML-Simple-2
	 dev-lang/perl"
DEPEND="${RDEPEND}"

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS ChangeLog NEWS README
}
