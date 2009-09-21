# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Test-ClassAPI/Test-ClassAPI-1.06.ebuild,v 1.5 2009/09/19 16:36:10 nixnut Exp $

EAPI=2

MODULE_AUTHOR=ADAMK
inherit perl-module

DESCRIPTION="Provides basic first-pass API testing for large class trees"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

RDEPEND=">=virtual/perl-File-Spec-0.83
	virtual/perl-Test-Simple
	>=dev-perl/Class-Inspector-1.12
	dev-perl/Config-Tiny
	>=dev-perl/Params-Util-1.00"
DEPEND="${RDEPEND}"

SRC_TEST=do
