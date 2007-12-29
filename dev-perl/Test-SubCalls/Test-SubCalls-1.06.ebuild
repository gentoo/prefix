# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-SubCalls/Test-SubCalls-1.06.ebuild,v 1.5 2007/12/27 13:53:16 ticho Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Track the number of times subs are called"
HOMEPAGE="http://search.cpan.org/search?query=${PN}"
SRC_URI="mirror://cpan/authors/id/A/AD/ADAMK/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~sparc-solaris ~x86 ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND=">=dev-perl/Hook-LexWrap-0.20
	dev-lang/perl"
