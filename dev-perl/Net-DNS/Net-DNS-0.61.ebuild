# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Net-DNS/Net-DNS-0.61.ebuild,v 1.8 2008/03/28 09:14:44 jer Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Perl Net::DNS - Perl DNS Resolver Module"
HOMEPAGE="http://search.cpan.org/~olaf/${P}/"
SRC_URI="mirror://cpan/authors/id/O/OL/OLAF/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="ipv6"

DEPEND="virtual/perl-Digest-MD5
	dev-perl/Digest-HMAC
	dev-perl/Net-IP
	ipv6? ( dev-perl/IO-Socket-INET6 )
	virtual/perl-MIME-Base64
	virtual/perl-Test-Simple
	dev-lang/perl"

SRC_TEST="do"
mydoc="TODO"
myconf="--no-online-tests"
