# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-Tabs+Wrap/Text-Tabs+Wrap-2006.1117.ebuild,v 1.1 2006/11/19 16:25:15 mcummings Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Expand/unexpand tabs per unix expand and line wrapping"
SRC_URI="mirror://cpan/authors/id/M/MU/MUIR/modules/${P}.tar.gz"
HOMEPAGE="http://www.cpan.org/modules/by-module/Text/${P}.readme"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""
SRC_TEST="do"


DEPEND="dev-lang/perl"
