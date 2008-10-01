# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Text-Glob/Text-Glob-0.08.ebuild,v 1.8 2008/09/30 15:16:51 tove Exp $

EAPI="prefix"

MODULE_AUTHOR=RCLAMP
inherit perl-module

DESCRIPTION="Match globbing patterns against text"

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

RDPEND="dev-lang/perl"
DEPEND="${RDEPEND}
	>=dev-perl/module-build-0.28"

SRC_TEST="do"
