# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-Tabs+Wrap/Text-Tabs+Wrap-2006.1117.ebuild,v 1.7 2007/11/10 14:57:00 drac Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Expand/unexpand tabs per unix expand and line wrapping"
SRC_URI="mirror://cpan/authors/id/M/MU/MUIR/modules/${P}.tar.gz"
HOMEPAGE="http://www.cpan.org/modules/by-module/Text/${P}.readme"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""
SRC_TEST="do"

DEPEND="dev-lang/perl"
