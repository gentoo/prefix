# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Socket6/Socket6-0.19.ebuild,v 1.16 2007/07/10 23:33:33 mr_bones_ Exp $

inherit perl-module

DESCRIPTION="IPv6 related part of the C socket.h defines and structure manipulators"
HOMEPAGE="http://search.cpan.org/author/UMEMOTO/"
SRC_URI="mirror://cpan/authors/id/U/UM/UMEMOTO/${P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
