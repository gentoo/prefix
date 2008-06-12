# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Class-Singleton/Class-Singleton-1.4.ebuild,v 1.1 2008/04/29 04:14:51 yuval Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Implementation of a Singleton class"
HOMEPAGE="http://search.cpan.org/~abw/"
SRC_URI="mirror://cpan/authors/id/A/AB/ABW/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
DEPEND="dev-lang/perl"
