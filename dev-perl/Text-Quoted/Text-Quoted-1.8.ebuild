# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-Quoted/Text-Quoted-1.8.ebuild,v 1.8 2006/08/18 01:54:22 mcummings Exp $

EAPI="prefix"

# this is an RT dependency

inherit perl-module

DESCRIPTION="Extract the structure of a quoted mail message"
SRC_URI="mirror://cpan/authors/id/J/JE/JESSE/${P}.tar.gz"
HOMEPAGE="http://www.cpan.org/modules/by-authors/id/J/JE/JESSE/${P}.readme"

SRC_TEST="do"
SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"

DEPEND="dev-perl/text-autoformat
	dev-perl/Text-Tabs+Wrap
	dev-lang/perl"
RDEPEND="${DEPEND}"
IUSE=""

