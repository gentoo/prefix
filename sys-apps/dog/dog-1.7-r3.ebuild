# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/dog/dog-1.7-r3.ebuild,v 1.8 2009/06/04 19:44:13 klausman Exp $

inherit eutils toolchain-funcs

DESCRIPTION="Dog is better than cat"
# the best HOMEPAGE we have.
HOMEPAGE="http://packages.gentoo.org/package/sys-apps/dog"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc64-solaris"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch ${FILESDIR}/${P}-check-ctime.diff
	epatch ${FILESDIR}/${PV}-manpage-touchup.patch
	epatch ${FILESDIR}/${P}-64bit-goodness.patch
	epatch ${FILESDIR}/${P}-strfry.patch

	if [[ "${CHOST}" == *-solaris* ]]
	then
		sed -i '/gcc.*-o dog/s/$/ -lsocket/' \
			Makefile || die "sed Makefile failed"
	fi

	sed -i \
		-e 's,^CFLAGS,#CFLAGS,' \
		-e "s,gcc,$(tc-getCC)," \
		Makefile || die "sed Makefile failed"
}

src_install() {
	dobin dog || die
	doman dog.1
	dodoc README AUTHORS
}
