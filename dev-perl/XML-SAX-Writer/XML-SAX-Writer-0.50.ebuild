# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/XML-SAX-Writer/XML-SAX-Writer-0.50.ebuild,v 1.11 2008/03/19 02:32:05 jer Exp $

EAPI="prefix"

inherit perl-module eutils

DESCRIPTION="SAX2 Writer"
HOMEPAGE="http://search.cpan.org/~dahut/${P}"
SRC_URI="mirror://cpan/authors/id/D/DA/DAHUT/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="dev-perl/Text-Iconv
	dev-perl/XML-Filter-BufferText
	dev-perl/XML-SAX
	>=dev-perl/XML-NamespaceSupport-1.04
	>=dev-libs/libxml2-2.4.1
	dev-lang/perl"

SRC_TEST="do"
