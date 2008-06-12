# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/XML-XQL/XML-XQL-0.68.ebuild,v 1.18 2007/01/19 17:48:41 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="A Perl module that allows you to perform XQL queries on XML trees"
HOMEPAGE="http://search.cpan.org/~tjmather/"
SRC_URI="mirror://cpan/authors/id/T/TJ/TJMATHER/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND=">=dev-perl/libxml-perl-0.07-r1
	>=dev-perl/XML-DOM-1.39-r1
	>=dev-perl/Parse-Yapp-1.05
	dev-perl/libwww-perl
	>=dev-perl/DateManip-5.40-r1
	dev-lang/perl"
