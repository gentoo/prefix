# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/DateTime/DateTime-0.47.ebuild,v 1.7 2009/05/04 15:51:56 armin76 Exp $

inherit versionator
MY_P=${PN}-$(delete_version_separator 2)
S=${WORKDIR}/${MY_P}
MODULE_AUTHOR=DROLSKY
inherit perl-module

DESCRIPTION="A date and time object"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=">=dev-perl/Params-Validate-0.76
	>=virtual/perl-Time-Local-1.04
	>=dev-perl/DateTime-TimeZone-0.59
	>=dev-perl/DateTime-Locale-0.41
	dev-lang/perl"
RDEPEND="${DEPEND}"

SRC_TEST="do"
