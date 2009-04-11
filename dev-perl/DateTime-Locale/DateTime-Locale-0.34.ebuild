# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/DateTime-Locale/DateTime-Locale-0.34.ebuild,v 1.7 2008/11/18 14:42:41 tove Exp $

inherit versionator perl-module

MY_P="${PN}-$(delete_version_separator 2)"
S=${WORKDIR}/${MY_P}

DESCRIPTION="Localization support for DateTime"
HOMEPAGE="http://search.cpan.org/~drolsky/"
SRC_URI="mirror://cpan/authors/id/D/DR/DROLSKY/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE=""
SRC_TEST="do"

DEPEND=">=virtual/perl-Module-Build-0.28
		${RDEPEND}"
RDEPEND="dev-perl/Params-Validate
	dev-lang/perl"
