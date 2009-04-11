# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Params-Validate/Params-Validate-0.91.ebuild,v 1.1 2008/09/08 07:20:08 tove Exp $

MODULE_AUTHOR=DROLSKY
inherit perl-module

DESCRIPTION="A module to provide a flexible system for validation method/function call parameters"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl"

SRC_TEST="do"

src_install () {
	perl-module_src_install
	dohtml htdocs/*
}
