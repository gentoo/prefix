# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/IO-Socket-SSL/IO-Socket-SSL-1.31.ebuild,v 1.1 2009/09/26 07:44:49 tove Exp $

EAPI=2

MODULE_AUTHOR=SULLR
inherit perl-module

DESCRIPTION="Nearly transparent SSL encapsulation for IO::Socket::INET"

SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="idn"

DEPEND=">=dev-perl/Net-SSLeay-1.33
	virtual/perl-Scalar-List-Utils
	idn? ( dev-perl/Net-LibIDN )"
RDEPEND="${DEPEND}"

SRC_TEST="do"
