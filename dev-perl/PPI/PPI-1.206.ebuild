# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/PPI/PPI-1.206.ebuild,v 1.1 2009/08/22 22:57:57 tove Exp $

EAPI=2

MODULE_AUTHOR=ADAMK
inherit perl-module

DESCRIPTION="Parse, Analyze and Manipulate Perl (without perl)"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE="test"

SRC_TEST="do"

RDEPEND="
	>=virtual/perl-Scalar-List-Utils-1.20
	>=dev-perl/Params-Util-1.00
	>=dev-perl/Clone-0.30
	>=virtual/perl-Digest-MD5-2.35
	dev-perl/IO-String
	>=dev-perl/List-MoreUtils-0.16
	>=virtual/perl-Storable-2.17
	dev-lang/perl"
DEPEND="${RDEPEND}
	test? ( >=dev-perl/File-Remove-1.42
		>=virtual/perl-Test-Simple-0.86
		>=dev-perl/Test-NoWarnings-0.084
		>=virtual/perl-File-Spec-0.84
		dev-perl/Test-SubCalls
		dev-perl/Test-Object
		>=dev-perl/Test-ClassAPI-1.04 )"
