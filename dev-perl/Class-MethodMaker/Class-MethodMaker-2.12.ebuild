# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Class-MethodMaker/Class-MethodMaker-2.12.ebuild,v 1.5 2009/06/29 23:13:59 jer Exp $

MODULE_AUTHOR=SCHWIGON
MODULE_SECTION=class-methodmaker
inherit perl-module eutils

DESCRIPTION="Perl module for Class::MethodMaker"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
