# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/URI/URI-1.37.ebuild,v 1.2 2009/03/26 12:25:29 armin76 Exp $

MODULE_AUTHOR=GAAS

inherit perl-module

DESCRIPTION="A URI Perl Module"

LICENSE="Artistic"
SLOT="0"
KEYWORDS="~ppc-aix ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="virtual/perl-MIME-Base64
	dev-lang/perl"

SRC_TEST=no # see ChangeLog

mydoc="rfc2396.txt"
