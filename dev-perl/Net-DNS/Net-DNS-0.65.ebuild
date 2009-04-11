# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Net-DNS/Net-DNS-0.65.ebuild,v 1.1 2009/01/27 10:15:12 tove Exp $

MODULE_AUTHOR=OLAF
inherit perl-module

DESCRIPTION="Perl Net::DNS - Perl DNS Resolver Module"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="ipv6 test"

RDEPEND="virtual/perl-Digest-MD5
	dev-perl/Digest-HMAC
	dev-perl/Net-IP
	ipv6? ( dev-perl/IO-Socket-INET6 )
	virtual/perl-MIME-Base64
	dev-lang/perl"
DEPEND="${RDEPEND}
	test? ( virtual/perl-Test-Simple
		dev-perl/Test-Pod )"

PATCHES=( ${FILESDIR}/${PN}-0.64-ar.patch )
SRC_TEST="do"
mydoc="TODO"
myconf="--no-online-tests"
