# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/libxml-perl/libxml-perl-0.08.ebuild,v 1.15 2007/01/16 01:11:50 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Collection of Perl modules for working with XML"
SRC_URI="mirror://cpan/modules/by-module/XML/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~kmacleod/"

SLOT="0"
LICENSE="Artistic"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND=">=dev-perl/XML-Parser-2.29
	dev-lang/perl"
