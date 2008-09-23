# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/IO-Socket-SSL/IO-Socket-SSL-1.16.ebuild,v 1.1 2008/09/20 08:01:22 tove Exp $

EAPI="prefix"

MODULE_AUTHOR=SULLR
inherit perl-module

DESCRIPTION="Nearly transparent SSL encapsulation for IO::Socket::INET"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""
SRC_TEST="do"

DEPEND=">=dev-perl/Net-SSLeay-1.33
	virtual/perl-Scalar-List-Utils
	dev-lang/perl
	dev-perl/Net-LibIDN"
