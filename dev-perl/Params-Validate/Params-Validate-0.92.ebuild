# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Params-Validate/Params-Validate-0.92.ebuild,v 1.2 2009/09/28 11:07:49 tove Exp $

EAPI=2

MODULE_AUTHOR=DROLSKY
inherit perl-module

DESCRIPTION="A module to provide a flexible system for validation method/function call parameters"

SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	>=virtual/perl-Module-Build-0.35"

SRC_TEST="do"
