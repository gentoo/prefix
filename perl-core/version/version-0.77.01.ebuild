# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/version/version-0.77.01.ebuild,v 1.2 2009/09/03 14:15:25 tove Exp $

EAPI=2

inherit versionator
MY_P=${PN}-$(delete_version_separator 2 )
S=${WORKDIR}/${MY_P}
MODULE_AUTHOR=JPEACOCK
inherit perl-module

DESCRIPTION="Perl extension for Version Objects"

SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	>=virtual/perl-Module-Build-0.33.05"

SRC_TEST="do"
