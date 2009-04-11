# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Perl-Critic/Perl-Critic-1.092.ebuild,v 1.1 2008/12/08 02:40:16 robbat2 Exp $

inherit versionator
MODULE_AUTHOR="THALJEF"
MODULE_SECTION=perlcritic
MY_P="${PN}-$(delete_version_separator 2)"
inherit perl-module

S=${WORKDIR}/${MY_P}

DESCRIPTION="Critique Perl source code for best-practices"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE=""

SRC_TEST="do"

RDEPEND=">=virtual/perl-Module-Pluggable-3.1
	>=dev-perl/Config-Tiny-2
	dev-perl/List-MoreUtils
	dev-perl/IO-String
	dev-perl/String-Format
	dev-perl/perltidy
	>=dev-perl/PPI-1.203
	>=dev-perl/set-scalar-1.20
	dev-perl/B-Keywords
	dev-perl/Readonly
	dev-perl/Exception-Class
	virtual/perl-version
	dev-lang/perl"
DEPEND="${RDEPEND}
	virtual/perl-Module-Build"

mydoc="extras/* examples/*"
