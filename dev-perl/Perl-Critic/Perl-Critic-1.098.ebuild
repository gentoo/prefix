# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Perl-Critic/Perl-Critic-1.098.ebuild,v 1.1 2009/03/08 18:43:17 tove Exp $

EAPI=2

#inherit versionator
MODULE_AUTHOR=ELLIOTJS
#MY_P="${PN}-$(delete_version_separator 2)"
inherit perl-module

#S=${WORKDIR}/${MY_P}

DESCRIPTION="Critique Perl source code for best-practices"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos ~sparc-solaris"
IUSE="test"

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
	virtual/perl-version"
DEPEND="${RDEPEND}
	virtual/perl-Module-Build
	test? ( dev-perl/Test-Deep
		dev-perl/PadWalker
		dev-perl/Test-Memory-Cycle
		dev-perl/Test-Pod
		dev-perl/Test-Pod-Coverage )"

mydoc="extras/* examples/*"

SRC_TEST="do"
