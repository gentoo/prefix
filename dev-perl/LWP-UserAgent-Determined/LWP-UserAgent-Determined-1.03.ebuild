# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/LWP-UserAgent-Determined/LWP-UserAgent-Determined-1.03.ebuild,v 1.1 2008/08/22 15:49:48 tove Exp $

MODULE_AUTHOR=SBURKE
inherit perl-module

DESCRIPTION="A virtual browser that retries errors"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl
	dev-perl/libwww-perl"

SRC_TEST=no
