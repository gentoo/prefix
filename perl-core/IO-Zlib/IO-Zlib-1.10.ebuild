# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/IO-Zlib/IO-Zlib-1.10.ebuild,v 1.2 2009/07/19 18:03:23 tove Exp $

EAPI=2

MODULE_AUTHOR=TOMHUGHES
inherit perl-module

DESCRIPTION="IO:: style interface to Compress::Zlib"

SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="virtual/perl-IO-Compress"
DEPEND="${RDEPEND}"

SRC_TEST="do"
