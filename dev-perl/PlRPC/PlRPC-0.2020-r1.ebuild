# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/PlRPC/PlRPC-0.2020-r1.ebuild,v 1.10 2009/10/22 12:55:17 tove Exp $

MODULE_AUTHOR=MNOONING
MODULE_SECTION=${PN}
inherit perl-module

S=${WORKDIR}/${PN}

DESCRIPTION="The Perl RPC Module"

SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=virtual/perl-Storable-1.0.7
	>=dev-perl/Net-Daemon-0.34
	dev-lang/perl"
DEPEND="${RDEPEND}"

PATCHES=( "${FILESDIR}/perldoc-remove.patch" )
