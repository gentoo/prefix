# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Number-Compare/Number-Compare-0.01.ebuild,v 1.18 2007/07/10 23:33:28 mr_bones_ Exp $

inherit perl-module

DESCRIPTION="numeric comparisons"
SRC_URI="mirror://cpan/authors/id/R/RC/RCLAMP/${P}.tar.gz"
HOMEPAGE="http://search.cpan.org/~rclamp/"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="dev-lang/perl"
