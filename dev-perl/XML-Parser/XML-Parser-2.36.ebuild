# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/XML-Parser/XML-Parser-2.36.ebuild,v 1.1 2008/04/29 00:27:30 yuval Exp $

EAPI="prefix"

inherit perl-module multilib

DESCRIPTION="A Perl extension interface to James Clark's XML parser, expat"
HOMEPAGE="http://search.cpan.org/~msergeant/"
SRC_URI="mirror://cpan/authors/id/M/MS/MSERGEANT/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=">=dev-libs/expat-1.95.1-r1
	dev-lang/perl"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i \
		-e "s:^\$expat_libpath.*:\$expat_libpath = '/usr/$(get_libdir)';:" \
		Makefile.PL || die "sed failed"
}
