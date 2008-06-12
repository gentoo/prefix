# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Net-IP/Net-IP-1.25-r1.ebuild,v 1.3 2007/07/10 23:33:27 mr_bones_ Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Perl extension for manipulating IPv4/IPv6 addresses"
HOMEPAGE="http://search.cpan.org/search?module=Net::IP"
SRC_URI="mirror://cpan/authors/id/M/MA/MANU/${P}.tar.gz"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

PATCHES="${FILESDIR}/initip-0.patch"
SRC_TEST="do"

mydoc="TODO"

DEPEND="dev-lang/perl"
