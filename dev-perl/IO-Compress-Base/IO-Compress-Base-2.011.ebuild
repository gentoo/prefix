# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/IO-Compress-Base/IO-Compress-Base-2.011.ebuild,v 1.1 2008/05/20 15:39:19 tove Exp $

EAPI="prefix"

MODULE_AUTHOR=PMQS

inherit perl-module

DESCRIPTION="Base Class for IO::Compress modules"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="virtual/perl-Scalar-List-Utils
	dev-lang/perl"

SRC_TEST="do"
