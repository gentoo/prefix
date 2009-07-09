# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Term-ANSIColor/Term-ANSIColor-2.01.ebuild,v 1.1 2009/07/05 12:42:04 tove Exp $

EAPI=2

MY_PN="ANSIColor"
MY_P="${MY_PN}-${PV}"
S="${WORKDIR}/${MY_P}"
MODULE_AUTHOR=RRA
inherit perl-module

DESCRIPTION="Color screen output using ANSI escape sequences."

SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="test"

RDEPEND=""
DEPEND="${RDEPEND}
	test? ( dev-perl/Test-Pod )"

SRC_TEST="do"
