# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/perl-Getopt-Long/perl-Getopt-Long-2.38.ebuild,v 1.3 2009/08/25 10:56:51 tove Exp $

DESCRIPTION="Virtual for Getopt-Long"
HOMEPAGE="http://www.gentoo.org/proj/en/perl/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

RDEPEND="|| ( ~dev-lang/perl-5.10.1 ~perl-core/Getopt-Long-${PV} )"
