# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Geography-Countries/Geography-Countries-2009041301.ebuild,v 1.1 2009/04/14 11:47:58 tove Exp $

EAPI=2

MODULE_AUTHOR=ABIGAIL
inherit perl-module

DESCRIPTION="2-letter, 3-letter, and numerical codes for countries."

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
