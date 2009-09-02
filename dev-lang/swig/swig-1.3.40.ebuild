# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/swig/swig-1.3.40.ebuild,v 1.1 2009/08/31 13:05:43 hkbst Exp $

inherit mono #48511

DESCRIPTION="Simplified Wrapper and Interface Generator"
HOMEPAGE="http://www.swig.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~ppc-aix ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc"

DEPEND=""
RDEPEND=""

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ANNOUNCE CHANGES CHANGES.current FUTURE NEW README TODO
	use doc && dohtml -r Doc/{Devel,Manual}
}
