# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/XML-LibXSLT/XML-LibXSLT-1.62.ebuild,v 1.9 2007/05/05 18:10:00 dertobi123 Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="A Perl module to parse XSL Transformational sheets using gnome's libXSLT"
SRC_URI="mirror://cpan/authors/id/P/PA/PAJAS/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~pajas/"

SLOT="0"
LICENSE="Artistic"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND=">=dev-libs/libxslt-1.1.2
	>=dev-perl/XML-LibXML-1.60
	dev-lang/perl"
