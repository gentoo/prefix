# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/MailTools/MailTools-2.05.ebuild,v 1.1 2009/12/19 11:19:51 tove Exp $

EAPI=2

MODULE_AUTHOR=MARKOV
inherit perl-module

DESCRIPTION="Manipulation of electronic mail addresses"

SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE="test"

RDEPEND=">=virtual/perl-libnet-1.0703
	dev-perl/TimeDate"
DEPEND="${RDEPEND}
	test? ( dev-perl/Test-Pod )"

SRC_TEST="do"
