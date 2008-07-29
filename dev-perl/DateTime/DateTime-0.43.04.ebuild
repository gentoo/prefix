# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/DateTime/DateTime-0.43.04.ebuild,v 1.1 2008/07/28 10:03:25 tove Exp $

EAPI="prefix"

inherit versionator
MODULE_PV=$(delete_version_separator 2)
MODULE_AUTHOR=DROLSKY
S=${WORKDIR}/${PN}-${MODULE_PV}
inherit perl-module

DESCRIPTION="A date and time object"
SRC_URI="mirror://cpan/authors/id/D/DR/DROLSKY/${PN}-${MODULE_PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE=""

SRC_TEST="do"

DEPEND=">=dev-perl/Params-Validate-0.76
	>=virtual/perl-Time-Local-1.04
	>=dev-perl/DateTime-TimeZone-0.59
	>=dev-perl/DateTime-Locale-0.41
	dev-lang/perl"
