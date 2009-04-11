# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/DateTime-Locale/DateTime-Locale-0.42.ebuild,v 1.7 2009/01/11 21:33:23 maekke Exp $

inherit versionator perl-module

MY_P="${PN}-$(delete_version_separator 2)"
S=${WORKDIR}/${MY_P}

DESCRIPTION="Localization support for DateTime"
SRC_URI="mirror://cpan/authors/id/D/DR/DROLSKY/${MY_P}.tar.gz"

LICENSE="|| ( Artistic GPL-2 ) unicode"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~x86-solaris"
IUSE=""
SRC_TEST="do"

RDEPEND="dev-perl/Params-Validate
	dev-perl/List-MoreUtils
	dev-lang/perl"
DEPEND=">=virtual/perl-Module-Build-0.28
	${RDEPEND}"
