# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Net-DNS/Net-DNS-0.63.ebuild,v 1.8 2008/11/04 10:20:27 vapier Exp $

MODULE_AUTHOR=OLAF
inherit perl-module

DESCRIPTION="Perl Net::DNS - Perl DNS Resolver Module"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="ipv6"

RDEPEND="virtual/perl-Digest-MD5
	dev-perl/Digest-HMAC
	dev-perl/Net-IP
	ipv6? ( dev-perl/IO-Socket-INET6 )
	virtual/perl-MIME-Base64
	dev-lang/perl"
DEPEND="${RDEPEND}
	virtual/perl-Test-Simple"

SRC_TEST="do"
mydoc="TODO"
myconf="--no-online-tests"
