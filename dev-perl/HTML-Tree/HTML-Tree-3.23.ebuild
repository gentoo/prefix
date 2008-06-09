# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/HTML-Tree/HTML-Tree-3.23.ebuild,v 1.13 2008/06/07 12:01:16 aballier Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="A library to manage HTML-Tree in PERL"
HOMEPAGE="http://search.cpan.org/dist/"
SRC_URI="mirror://cpan/authors/id/P/PE/PETEK/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=">=dev-perl/HTML-Tagset-3.03
	>=dev-perl/HTML-Parser-3.46
	dev-lang/perl"

SRC_TEST="do"

mydoc="MANIFEST README"
