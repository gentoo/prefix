# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/xlhtml/xlhtml-0.5.ebuild,v 1.14 2007/01/07 00:43:13 masterdriverz Exp $

EAPI="prefix"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit autotools

DESCRIPTION="Convert MS Excel and Powerpoint files to HTML"
HOMEPAGE="http://chicago.sourceforge.net/xlhtml/"
SRC_URI="mirror://sourceforge/chicago/${P}.tgz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""
DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	# This is needed specifically for depcomp, which is necessary for
	# building xlhtml, but isn't included.
	eautoreconf
}

src_install() {
	make DESTDIR=${D} install || die "make install failed for ${P}"
	dodoc AUTHORS COPYING INSTALL README
	docinto cole
	dodoc cole/{AUTHORS,COPYING,NEWS,ChangeLog,THANKS,TODO}
	docinto ppthtml
	dodoc ppthtml/{ChangeLog,README,THANKS}
	docinto xlhtml
	dodoc xlhtml/{ChangeLog,README,THANKS,TODO}
	rm -rf xlhtml/contrib/CVS
	cp -pPR xlhtml/contrib "${ED}/usr/share/doc/${PF}/xlhtml"
}
