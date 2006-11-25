# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/perl-Scalar-List-Utils/perl-Scalar-List-Utils-1.18.ebuild,v 1.11 2006/11/12 03:18:45 vapier Exp $

EAPI="prefix"

DESCRIPTION="Virtual for Scalar-List-Utils"
HOMEPAGE="http://www.gentoo.org/proj/en/perl/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE=""

DEPEND=""
RDEPEND="|| ( ~dev-lang/perl-5.8.8 ~perl-core/Scalar-List-Utils-${PV} )"
