# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/PPI/PPI-1.118.ebuild,v 1.4 2007/12/27 13:53:42 ticho Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Parse, Analyze and Manipulate Perl (without perl)"
HOMEPAGE="http://search.cpan.org/search?query=${PN}"
SRC_URI="mirror://cpan/authors/id/A/AD/ADAMK/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64 ~sparc-solaris ~x86 ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-perl/File-Remove
		virtual/perl-File-Spec
		dev-perl/Test-SubCalls
		dev-perl/Test-ClassAPI
		dev-perl/IO-stringy
		>=virtual/perl-Scalar-List-Utils-1.17
		>=dev-perl/Params-Util-0.10
		>=dev-perl/Clone-0.17
		dev-perl/Test-Object
		dev-perl/Task-Weaken
		virtual/perl-Digest-MD5
		dev-perl/IO-String
		dev-perl/List-MoreUtils
	dev-lang/perl"
