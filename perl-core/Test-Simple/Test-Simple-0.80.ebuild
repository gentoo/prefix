# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/perl-core/Test-Simple/Test-Simple-0.80.ebuild,v 1.2 2008/06/06 09:01:14 aballier Exp $

EAPI="prefix"

MODULE_AUTHOR=MSCHWERN

inherit perl-module

DESCRIPTION="Basic utilities for writing tests"

LICENSE="|| ( Artistic GPL-2 )"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

mydoc="rfc*.txt"
myconf="INSTALLDIRS=vendor"
DEPEND=">=dev-lang/perl-5.8.0-r12"

SRC_TEST="do"
