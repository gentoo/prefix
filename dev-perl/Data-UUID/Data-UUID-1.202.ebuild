# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Data-UUID/Data-UUID-1.202.ebuild,v 1.5 2009/10/07 23:17:31 tcunha Exp $

EAPI=2

MODULE_AUTHOR=RJBS
inherit perl-module

DESCRIPTION="Perl extension for generating Globally/Universally Unique Identifiers (GUIDs/UUIDs)"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

RDEPEND="virtual/perl-Digest-MD5"
DEPEND="${RDEPEND}"

SRC_TEST="do"
