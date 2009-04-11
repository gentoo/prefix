# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/pmake/pmake-0.ebuild,v 1.5 2008/01/02 12:43:20 grobian Exp $

DESCRIPTION="Virtual for BSD-like make"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

RDEPEND="kernel_linux? ( sys-devel/pmake )
	kernel_Solaris? ( sys-devel/pmake )
	kernel_Darwin? ( sys-devel/bsdmake )"
