# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/MailTools/MailTools-1.77.ebuild,v 1.6 2007/11/10 13:59:04 drac Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Manipulation of electronic mail addresses"
SRC_URI="mirror://cpan/authors/id/M/MA/MARKOV/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~markov/"

SLOT="0"
LICENSE="Artistic"
KEYWORDS="~amd64 ~ia64 ~mips ~x86 ~x86-fbsd ~x86-macos"
IUSE=""
SRC_TEST="do"

DEPEND=">=virtual/perl-libnet-1.0703
	dev-lang/perl"
