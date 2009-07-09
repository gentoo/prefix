# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/LWP-UserAgent-Determined/LWP-UserAgent-Determined-1.04.ebuild,v 1.3 2009/07/03 06:19:52 tove Exp $

EAPI=2

MODULE_AUTHOR=JESSE
inherit perl-module

DESCRIPTION="A virtual browser that retries errors"

SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND="dev-perl/libwww-perl"

SRC_TEST=no
