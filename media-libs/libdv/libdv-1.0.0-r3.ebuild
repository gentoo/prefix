# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libdv/libdv-1.0.0-r3.ebuild,v 1.7 2014/07/28 13:45:41 ago Exp $

EAPI=4

inherit eutils libtool flag-o-matic multilib-minimal

DESCRIPTION="Software codec for dv-format video (camcorders etc)"
HOMEPAGE="http://libdv.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz
	mirror://gentoo/${PN}-1.0.0-pic.patch.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="static-libs"

RDEPEND="dev-libs/popt
	abi_x86_32? ( !<=app-emulation/emul-linux-x86-medialibs-20130224-r12
		!app-emulation/emul-linux-x86-medialibs[-abi_x86_32(-)] )"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

DOCS=( AUTHORS ChangeLog INSTALL NEWS TODO )

src_prepare() {
	epatch "${FILESDIR}"/${PN}-0.99-2.6.patch
	epatch "${WORKDIR}"/${PN}-1.0.0-pic.patch
	epatch "${FILESDIR}"/${PN}-1.0.0-solaris.patch
	epatch "${FILESDIR}"/${PN}-1.0.0-darwin.patch
	elibtoolize
	epunt_cxx #74497

	append-cppflags "-I${S}"
}

multilib_src_configure() {
	ECONF_SOURCE="${S}"	econf \
		$(use_enable static-libs static) \
		--without-debug \
		--disable-gtk \
		--disable-gtktest \
		$(use x86-macos && echo "--disable-asm") \
		$(use x64-macos && echo "--disable-asm")
	if ! multilib_is_native_abi ; then
		sed -i \
			-e 's/ encodedv//' \
			Makefile || die
	fi
}

multilib_src_install_all() {
	prune_libtool_files --all
	einstalldocs
}
