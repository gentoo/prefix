# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/PPI/PPI-1.203.ebuild,v 1.1 2008/07/28 07:05:46 tove Exp $

MODULE_AUTHOR=ADAMK
inherit perl-module

DESCRIPTION="Parse, Analyze and Manipulate Perl (without perl)"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE="test"

SRC_TEST="do"

RDEPEND="
	>=virtual/perl-Scalar-List-Utils-1.19
	>=dev-perl/Params-Util-0.10
	>=dev-perl/Clone-0.25
	dev-perl/Task-Weaken
	virtual/perl-Digest-MD5
	dev-perl/IO-String
	>=dev-perl/List-MoreUtils-0.16
	dev-lang/perl"
DEPEND="${RDEPEND}
	test? ( >=dev-perl/File-Remove-0.39
		virtual/perl-File-Spec
		dev-perl/Test-SubCalls
		dev-perl/Test-Object
		dev-perl/Test-ClassAPI )"
