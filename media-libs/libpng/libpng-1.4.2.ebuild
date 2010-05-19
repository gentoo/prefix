# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libpng/libpng-1.4.2.ebuild,v 1.4 2010/05/13 20:05:17 ssuominen Exp $

EAPI=3
inherit libtool

DESCRIPTION="Portable Network Graphics library"
HOMEPAGE="http://www.libpng.org/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.xz"

LICENSE="as-is"
KEYWORDS="~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
SLOT="0"

IUSE=""

RDEPEND="sys-libs/zlib
	!<media-libs/libpng-1.2.43-r1"
DEPEND="${RDEPEND}
	app-arch/xz-utils"

src_prepare() {
	cp "${FILESDIR}"/libpng-1.4.x-update.sh "${T}"/ || die
	sed -i \
		-e 's:-d /usr/lib64:-d '"${EPREFIX}"'/usr/lib64:' \
		-e 's:^libdir=:libdir='"${EPREFIX}"':' \
		"${T}"/libpng-1.4.x-update.sh || die

	elibtoolize
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc ANNOUNCE CHANGES README TODO || die
	dosbin "${T}"/libpng-1.4.x-update.sh || die
}

pkg_postinst() {
	echo
	ewarn "Moving from libpng 1.2.x to 1.4.x will break installed libtool .la"
	ewarn "files."
	echo
	elog "Run ${EPREFIX}/usr/sbin/libpng-1.4.x-update.sh at your own risk only if"
	elog "revdep-rebuild fails."
	echo
	elog "Don't forget \"man emerge\" and useful parameters like --skip-first,"
	elog "--resume and --keep-going."
	echo
}
