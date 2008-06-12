# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-ClassAPI/Test-ClassAPI-1.04-r1.ebuild,v 1.6 2008/03/28 09:49:07 jer Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Provides basic first-pass API testing for large class trees"
SRC_URI="mirror://cpan/authors/id/A/AD/ADAMK/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~adamk/"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

DEPEND=">=virtual/perl-File-Spec-0.83
	virtual/perl-Test-Simple
		>=dev-perl/Class-Inspector-1.06
		dev-perl/Config-Tiny
		>=dev-perl/Params-Util-0.10
	dev-lang/perl"
