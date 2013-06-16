# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/flac/flac-1.2.1-r4.ebuild,v 1.4 2013/04/25 19:02:23 radhermit Exp $

EAPI=2
inherit autotools eutils

DESCRIPTION="free lossless audio encoder and decoder"
HOMEPAGE="http://flac.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz
	mirror://gentoo/${P}-embedded-m4.tar.bz2"

LICENSE="BSD FDL-1.2 GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="3dnow altivec +cxx debug ogg sse static-libs"

RDEPEND="ogg? ( >=media-libs/libogg-1.1.3 )"
DEPEND="${RDEPEND}
	x86? ( dev-lang/nasm )
	!elibc_uclibc? ( sys-devel/gettext )
	virtual/pkgconfig"

src_prepare() {
	epatch \
		"${FILESDIR}"/${P}-asneeded.patch \
		"${FILESDIR}"/${P}-cflags.patch \
		"${FILESDIR}"/${P}-asm.patch \
		"${FILESDIR}"/${P}-dontbuild-tests.patch \
		"${FILESDIR}"/${P}-dontbuild-examples.patch \
		"${FILESDIR}"/${P}-gcc-4.3-includes.patch \
		"${FILESDIR}"/${P}-ogg-m4.patch \
		"${FILESDIR}"/${P}-irix.patch

	cp "${WORKDIR}"/*.m4 m4 || die

	# bug 466990
	sed -i "s/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/" configure.in || die

	AT_M4DIR="m4" eautoreconf
}

src_configure() {
	local myconf
	[[ ${CHOST} == *-darwin* ]] && myconf="--disable-asm-optimizations"
	econf \
		$(use_enable static-libs static) \
		--disable-dependency-tracking \
		$(use_enable debug) \
		$(use_enable sse) \
		$(use_enable 3dnow) \
		$(use_enable altivec) \
		--disable-doxygen-docs \
		--disable-xmms-plugin \
		$(use_enable cxx cpplibs) \
		$(use_enable ogg) \
		--disable-examples \
		${myconf}
}

src_test() {
	if [ $UID != 0 ]; then
		emake check || die
	else
		ewarn "Tests will fail if ran as root, skipping."
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die

	rm -rf "${ED}"/usr/share/doc/${P}
	dodoc AUTHORS README
	dohtml -r doc/html/*

	find "${ED}" -name '*.la' -exec rm -f '{}' +
}

pkg_postinst() {
	ewarn "If you've upgraded from a previous version of flac, you may need to re-emerge"
	ewarn "packages that linked against flac by running revdep-rebuild"
}
