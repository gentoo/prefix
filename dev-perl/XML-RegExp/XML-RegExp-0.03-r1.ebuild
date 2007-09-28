# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/XML-RegExp/XML-RegExp-0.03-r1.ebuild,v 1.18 2007/01/19 17:41:32 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="A Perl module which contains contains regular expressions for the following XML tokens: BaseChar, Ideographic, Letter, Digit, Extender, CombiningChar, NameChar, EntityRef, CharRef, Reference, Name, NmToken, and AttValue."
SRC_URI="mirror://cpan/authors/id/T/TJ/TJMATHER/${P}.tar.gz"
HOMEPAGE="http://searchcpan.org/~tjmather/"

SLOT="0"
LICENSE="Artistic"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND=">=dev-perl/XML-Parser-2.29
	dev-lang/perl"
