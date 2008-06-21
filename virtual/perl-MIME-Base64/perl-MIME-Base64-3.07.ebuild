# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/perl-MIME-Base64/perl-MIME-Base64-3.07.ebuild,v 1.15 2008/06/07 12:04:29 aballier Exp $

EAPI="prefix"

DESCRIPTION="Virtual for MIME-Base64"
HOMEPAGE="http://www.gentoo.org/proj/en/perl/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND="|| ( >=dev-lang/perl-5.8.8 ~perl-core/MIME-Base64-${PV} )"
