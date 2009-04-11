# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Config-Simple/Config-Simple-4.58.ebuild,v 1.9 2007/01/15 15:11:31 mcummings Exp $

inherit perl-module

DESCRIPTION="Config::Simple - simple configuration file class."
SRC_URI="mirror://cpan/authors/id/S/SH/SHERZODR/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~sherzodr/"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

SRC_TEST="do"
DEPEND="dev-lang/perl"
