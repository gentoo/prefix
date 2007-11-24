# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/texi2html/texi2html-1.78.ebuild,v 1.1 2007/11/23 18:21:44 aballier Exp $

EAPI="prefix"

DESCRIPTION="Perl script that converts Texinfo to HTML"
HOMEPAGE="http://www.nongnu.org/texi2html/"
SRC_URI="http://download.savannah.gnu.org/releases/texi2html/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~mips ~ppc-macos ~sparc-solaris ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-lang/perl-5.6.1"

src_install() {
	#yes, htmldir line is correct, no ${D}
	emake DESTDIR="${D}" \
		htmldir="${EPREFIX}"/usr/share/doc/${PF}/html \
		install || die "Installation Failed"

	dodoc AUTHORS ChangeLog INTRODUCTION NEWS README TODO
}

pkg_preinst() {
	rm -f "${EROOT}"/usr/bin/texi2html
}
