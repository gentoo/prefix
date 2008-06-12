# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Algorithm-Annotate/Algorithm-Annotate-0.10.ebuild,v 1.15 2007/01/14 21:58:28 mcummings Exp $

EAPI="prefix"

inherit perl-module

HOMEPAGE="http://search.cpan.org/~clkao/"
DESCRIPTION="Algorithm::Annotate - represent a series of changes in annotate form"
SRC_URI="mirror://cpan/authors/id/C/CL/CLKAO/${P}.tar.gz"

SLOT="0"
LICENSE="Artistic"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""
SRC_TEST="do"

DEPEND=">=dev-perl/Algorithm-Diff-1.15
	dev-lang/perl"
