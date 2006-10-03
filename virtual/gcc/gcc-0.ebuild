# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/libiconv/libiconv-0.ebuild,v 1.1 2006/04/13 19:56:44 flameeyes Exp $

EAPI="prefix"

DESCRIPTION="Virtual for the GNU compiler"
HOMEPAGE="http://www.gentoo.org/proj/en/gentoo-alt/"
SRC_URI=""
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""
DEPEND=""

# For platforms that have a slightly different version of GCC (like Apple's OSX
# systems) here we can define that difference.  Note that this virtual is not
# meant for using another compiler than GNU's GCC.
RDEPEND="|| (
				elibc_Darwin? ( sys-devel/gcc-apple )
				sys-devel/gcc
			)"

src_install() {
	# shutup portage
	mkdir -p "${D}"
}
