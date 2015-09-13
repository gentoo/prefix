# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# Bridge the old SLOT=5[/5] ebuild to the new SLOT=0/5 since the slotmove
# functionality does not handle implicit subslots correctly. #558856

EAPI="5"

inherit multilib-build

DESCRIPTION="transitional package"
HOMEPAGE="https://www.gnu.org/software/ncurses/ http://dickey.his.com/ncurses/"

LICENSE="metapackage"
SLOT="5/5"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="ada +cxx gpm static-libs tinfo unicode"

DEPEND="sys-libs/ncurses:0/5[ada?,cxx?,gpm?,static-libs?,tinfo?,unicode?,${MULTILIB_USEDEP}]"
RDEPEND="${DEPEND}"
