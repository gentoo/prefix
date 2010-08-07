# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/gsm/gsm-1.0.13.ebuild,v 1.5 2010/07/29 17:35:54 ssuominen Exp $

EAPI=2
inherit eutils flag-o-matic multilib toolchain-funcs versionator

DESCRIPTION="Lossy speech compression library and tool."
HOMEPAGE="http://packages.qa.debian.org/libg/libgsm.html"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="gsm"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-solaris"
IUSE=""

S=${WORKDIR}/${PN}-"$(replace_version_separator 2 '-pl' )"

src_prepare() {
	epatch "${FILESDIR}"/${P}-shared.patch \
		"${FILESDIR}"/${PN}-1.0.12-memcpy.patch \
		"${FILESDIR}"/${PN}-1.0.12-64bit.patch
	[[ ${CHOST} == *-darwin* ]] && epatch "${FILESDIR}"/${PN}-1.0.12-darwin.patch
}

src_compile() {
	# From upstream Makefile. Define this if your host multiplies
	# floats faster than integers, e.g. on a SPARCstation.
	use sparc && append-flags -DUSE_FLOAT_MUL -DFAST

	emake -j1 CCFLAGS="${CFLAGS} -c -DNeedFunctionPrototypes=1" \
		LD="$(tc-getCC)" AR="$(tc-getAR)" CC="$(tc-getCC)" \
		GSM_INSTALL_LIB="${EPREFIX}"/usr/$(get_libdir) || die "emake failed."
}

src_install() {
	dodir /usr/bin /usr/$(get_libdir) /usr/include/gsm /usr/share/man/man{1,3}

	emake -j1 INSTALL_ROOT="${ED}"/usr \
		GSM_INSTALL_LIB="${ED}"/usr/$(get_libdir) \
		GSM_INSTALL_INC="${ED}"/usr/include/gsm \
		GSM_INSTALL_MAN="${ED}"/usr/share/man/man3 \
		TOAST_INSTALL_MAN="${ED}"/usr/share/man/man1 \
		install || die "emake install failed."

	dolib lib/libgsm*$(get_libname)*

	dosym ../gsm/gsm.h /usr/include/libgsm/gsm.h

	dodoc ChangeLog* MACHINES MANIFEST README
}
