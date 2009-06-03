# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/IPC-Run3/IPC-Run3-0.043.ebuild,v 1.1 2009/05/31 08:03:01 tove Exp $

EAPI=2

MODULE_AUTHOR=RJBS
inherit perl-module

DESCRIPTION="Run a subprocess in batch mode (a la system)"

SLOT="0"
LICENSE="as-is"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE="test"

SRC_TEST="do"

RDEPEND=""
DEPEND="${RDEPEND}
	test? ( >=dev-perl/Test-Pod-1.00
		>=dev-perl/Test-Pod-Coverage-1.04 )"
