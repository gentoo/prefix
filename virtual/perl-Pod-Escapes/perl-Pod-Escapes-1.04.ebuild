# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/perl-Pod-Escapes/perl-Pod-Escapes-1.04.ebuild,v 1.2 2008/11/03 16:47:39 mr_bones_ Exp $

DESCRIPTION="for resolving Pod E<...> sequences"
HOMEPAGE="http://www.gentoo.org/proj/en/perl/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"

IUSE=""
DEPEND=""

RDEPEND="|| ( ~dev-lang/perl-5.10.0 ~perl-core/Pod-Escapes-${PV} )"
