# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/iso-codes/iso-codes-3.9.ebuild,v 1.1 2009/06/03 22:28:09 eva Exp $

EAPI=2

DESCRIPTION="Provides the list of country and language names"
HOMEPAGE="http://alioth.debian.org/projects/pkg-isocodes/"
SRC_URI="ftp://pkg-isocodes.alioth.debian.org/pub/pkg-isocodes/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND=""
DEPEND="sys-devel/gettext
	|| (
		>=dev-lang/python-2.3[-build,xml]
		dev-python/pyxml )"

src_install() {
	emake DESTDIR="${D}" install || die "Installation failed"

	dodoc ChangeLog README TODO
}
