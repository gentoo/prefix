# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Net-SMTP-SSL/Net-SMTP-SSL-1.01.ebuild,v 1.10 2008/11/04 10:20:25 vapier Exp $

MODULE_AUTHOR="CWEST"
inherit perl-module

DESCRIPTION="SSL support for Net::SMTP"

IUSE=""

SLOT="0"
LICENSE="|| ( Artistic GPL-2 )"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc64-solaris ~x64-solaris"

DEPEND="dev-lang/perl
		virtual/perl-libnet
		dev-perl/IO-Socket-SSL"

mydoc="Changes README"
SRC_TEST="do"
