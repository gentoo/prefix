# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit base bash-completion-r1

DESCRIPTION="A nice emerge.log parser"
HOMEPAGE="https://www.gentoo.org/proj/en/perl"
SRC_URI="https://dev.gentoo.org/~dilfridge/distfiles/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x86-solaris"
IUSE=""

DEPEND="dev-lang/perl
	 dev-perl/Date-Manip
	 dev-perl/libwww-perl"
RDEPEND="${DEPEND}"

# Populate the patches array for any patches for -rX releases
PATCHES=( "${FILESDIR}"/${P}-sync.patch )

src_prepare() {
	default

	# ugly, but I'm not a perl guru
	[[ ${CHOST} == *-solaris* ]] && \
		sed -i -e 's/ps ax -o pid,args/ps -ef -o pid,args/' genlop
	[[ ${CHOST} == *-darwin* ]] && \
		sed -i -e 's/ps ax -o pid,args/ps ax -o pid,command/' genlop
}

src_install() {
	dobin genlop
	dodoc README Changelog
	doman genlop.1
	newbashcomp genlop.bash-completion genlop
}
