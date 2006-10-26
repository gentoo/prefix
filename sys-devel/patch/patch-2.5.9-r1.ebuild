# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/patch/patch-2.5.9-r1.ebuild,v 1.12 2006/09/07 16:23:15 vapier Exp $

EAPI="prefix"

inherit flag-o-matic eutils

DESCRIPTION="Utility to apply diffs to files"
HOMEPAGE="http://www.gnu.org/software/patch/patch.html"
#SRC_URI="mirror://gnu/patch/${P}.tar.gz"
#Using own mirrors until gnu has md5sum and all packages up2date
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="build static"

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	if type -p patch > /dev/null ; then
		epatch "${FILESDIR}"/patch-2.5.9-cr-stripping.patch
	fi
}

src_compile() {
	strip-flags
	use kernel_linux && append-flags -DLINUX
	append-flags -D_XOPEN_SOURCE=500
	use static && append-ldflags -static

	local myconf=""
	use gprefix && myconf="--program-prefix=g"
	ac_cv_sys_long_file_names=yes econf ${myconf} || die

	emake || die "emake failed"
}

src_install() {
	einstall || die
	dodoc AUTHORS ChangeLog NEWS README
	use build && rm -r "${ED}"/usr/share
}
