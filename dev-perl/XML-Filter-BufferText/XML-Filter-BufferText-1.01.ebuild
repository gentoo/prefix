# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/XML-Filter-BufferText/XML-Filter-BufferText-1.01.ebuild,v 1.23 2007/01/19 17:26:09 mcummings Exp $

inherit perl-module

DESCRIPTION="Filter to put all characters() in one event"
HOMEPAGE="http://search.cpan.org/~rberjon/"
SRC_URI="mirror://cpan/authors/id/R/RB/RBERJON/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND=">=dev-perl/XML-SAX-0.12
	dev-lang/perl"

SRC_TEST="do"
