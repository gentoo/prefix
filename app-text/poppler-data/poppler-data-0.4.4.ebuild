# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/poppler-data/poppler-data-0.4.4.ebuild,v 1.1 2010/10/29 16:58:08 reavertm Exp $

EAPI="2"

DESCRIPTION="Data files for poppler to support uncommon encodings without xpdfrc"
HOMEPAGE="http://poppler.freedesktop.org/"
SRC_URI="http://poppler.freedesktop.org/${P}.tar.gz"

LICENSE="BSD GPL-2 MIT"
KEYWORDS="~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
SLOT="0"
IUSE=""

src_install() {
	emake prefix="${EPREFIX}"/usr DESTDIR="${D}" install || die
	dodoc README
}
