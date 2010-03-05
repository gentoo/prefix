# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-vcs/rcs/rcs-5.7-r3.ebuild,v 1.1 2010/03/05 07:10:36 ulm Exp $

inherit eutils

DESCRIPTION="Revision Control System"
HOMEPAGE="http://www.gnu.org/software/rcs/"
SRC_URI="mirror://gnu/rcs/${P}.tar.gz
	mirror://gentoo/${P}-debian.diff.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE=""

RDEPEND="sys-apps/diffutils"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${WORKDIR}"/${P}-debian.diff
}

src_compile() {
	# econf BREAKS this!
	./configure \
		--prefix="${EPREFIX}"/usr \
		--host=${CHOST} \
		--with-diffutils || die

	emake || die
}

src_install() {
	make \
		prefix="${ED}"/usr \
		man1dir="${ED}"/usr/share/man/man1 \
		man3dir="${ED}"/usr/share/man/man3 \
		man5dir="${ED}"/usr/share/man/man5 \
		install || die

	dodoc ChangeLog CREDITS NEWS README REFS
}
