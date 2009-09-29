# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Class-MethodMaker/Class-MethodMaker-2.15.ebuild,v 1.7 2009/09/27 15:06:48 ranger Exp $

MODULE_AUTHOR=SCHWIGON
MODULE_SECTION=class-methodmaker
inherit perl-module eutils

DESCRIPTION="Perl module for Class::MethodMaker"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl"

SRC_TEST="do"
