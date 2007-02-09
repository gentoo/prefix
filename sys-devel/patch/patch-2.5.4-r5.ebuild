# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/sys-devel/patch/Attic/patch-2.5.4-r5.ebuild,v 1.10 2004/11/16 07:08:32 vapier dead $

EAPI="prefix"

RESTICT="mirror" # no longer there

DESCRIPTION="Utility to apply diffs to files"
HOMEPAGE="http://www.gnu.org/software/patch/patch.html"
SRC_URI="mirror://gnu/patch/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~sparc-solaris"
IUSE="build static"

DEPEND="virtual/libc"

src_compile() {
	CFLAGS="$CFLAGS -DLINUX -D_XOPEN_SOURCE=500"
	ac_cv_sys_long_file_names=yes \
		./configure --host=${CHOST} \
			--prefix="${EPREFIX}"/usr \
			--mandir="${EPREFIX}"/usr/share/man
	if ! use static; then
		emake || die "emake failed"
	else
		emake LDFLAGS=-static || die "emake failed"
	fi
}

src_install() {
	einstall
	if ! use build; then
		dodoc AUTHORS COPYING ChangeLog NEWS README
	else
		rm -rf ${ED}/usr/share/man
	fi
}
