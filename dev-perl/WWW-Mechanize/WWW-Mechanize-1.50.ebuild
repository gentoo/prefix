# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/WWW-Mechanize/WWW-Mechanize-1.50.ebuild,v 1.3 2008/10/29 22:12:40 gentoofan23 Exp $

EAPI="prefix"

MODULE_AUTHOR=PETDANCE
inherit perl-module

DESCRIPTION="Handy web browsing in a Perl object"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="test"

# Bug in the tests - improper use of HTTP::Server
SRC_TEST="do"

# configure to run the local tests, but not the ones which access the Internet
myconf="--local --nolive"

RDEPEND="dev-lang/perl
	dev-perl/IO-Socket-SSL
	>=dev-perl/libwww-perl-5.815
	dev-perl/HTTP-Response-Encoding
	>=dev-perl/URI-1.25
	>=dev-perl/HTML-Parser-3.34
	dev-perl/Test-LongString"
DEPEND="${RDEPEND}
	test? ( dev-perl/Test-Pod
		dev-perl/Test-Taint
		dev-perl/Test-Warn
		dev-perl/Test-Memory-Cycle )"
