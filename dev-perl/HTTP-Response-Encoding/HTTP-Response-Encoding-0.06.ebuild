# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/HTTP-Response-Encoding/HTTP-Response-Encoding-0.06.ebuild,v 1.1 2009/07/29 20:39:59 tove Exp $

EAPI=2

MODULE_AUTHOR=DANKOGAI
inherit perl-module

DESCRIPTION="Adds encoding() to HTTP::Response"

SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux"
IUSE="test"

RDEPEND="dev-perl/libwww-perl"
DEPEND="${RDEPEND}
	test? ( dev-perl/Test-Pod
		dev-perl/Test-Pod-Coverage )"

SRC_TEST=do
