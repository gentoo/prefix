# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Scalar-Properties/Scalar-Properties-0.12.ebuild,v 1.14 2008/03/19 02:24:51 jer Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="run-time properties on scalar variables"
HOMEPAGE="http://search.cpan.org/~dcantrell/"
SRC_URI="mirror://cpan/authors/id/D/DC/DCANTRELL/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
SRC_TEST="do"

DEPEND="dev-lang/perl"
