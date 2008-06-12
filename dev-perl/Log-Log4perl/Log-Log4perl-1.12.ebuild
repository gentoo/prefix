# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/Log-Log4perl/Log-Log4perl-1.12.ebuild,v 1.5 2007/11/10 13:42:41 drac Exp $

EAPI="prefix"

inherit perl-module

DESCRIPTION="Log::Log4perl is a Perl port of the widely popular log4j logging package."
SRC_URI="mirror://cpan/authors/id/M/MS/MSCHILLI/${P}.tar.gz"
HOMEPAGE="http://log4perl.sourceforge.net/"

SLOT="0"
LICENSE="as-is"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

SRC_TEST="do"

DEPEND="dev-lang/perl"
