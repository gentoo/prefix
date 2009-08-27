# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/perl-Time-Local/perl-Time-Local-1.19.01.ebuild,v 1.2 2009/08/25 10:56:58 tove Exp $

DESCRIPTION="Virtual for Time-Local"
HOMEPAGE="http://www.gentoo.org/proj/en/perl/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND="|| ( ~dev-lang/perl-5.10.1 ~perl-core/Time-Local-${PV} )"
