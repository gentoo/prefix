# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/flac/flac-1.2.1-r2.ebuild,v 1.5 2008/05/12 15:23:35 corsair Exp $

EAPI="prefix 1"

inherit autotools eutils

DESCRIPTION="free lossless audio encoder and decoder"
HOMEPAGE="http://flac.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz
	http://dev.gentoo.org/~drac/${P}-eautoreconf-gettext-0.17-m4.tar.bz2"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos"
IUSE="3dnow altivec +cxx debug doc ogg sse"

RDEPEND="ogg? ( >=media-libs/libogg-1.1.3 )"
DEPEND="${RDEPEND}
	x86? ( dev-lang/nasm )
	!elibc_uclibc? ( sys-devel/gettext )
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Stop using upstream CFLAGS. Fix building with
	# ldflag asneeded on non glibc systems. Fix
	# broken asm causing text relocations.
	epatch "${FILESDIR}"/${P}-asneeded.patch
	epatch "${FILESDIR}"/${P}-cflags.patch
	epatch "${FILESDIR}"/${P}-asm.patch

	# Fix build with gcc 4.3, bug #199579
	epatch "${FILESDIR}/${P}-gcc-4.3-includes.patch"

	AT_M4DIR="../m4 m4" eautoreconf
}

src_compile() {
	econf $(use_enable ogg) \
		$(use_enable sse) \
		$(use_enable 3dnow) \
		$(use_enable altivec) \
		$(use_enable debug) \
		$(use_enable cxx cpplibs) \
		--disable-doxygen-docs \
		--disable-dependency-tracking \
		--disable-xmms-plugin

	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."

	rm -rf "${ED}"/usr/share/doc/${P}
	dodoc AUTHORS README
	use doc && dohtml -r doc/html/*
}

pkg_postinst() {
	ewarn "If you've upgraded from a previous version of flac, you may need to re-emerge"
	ewarn "packages that linked against flac by running revdep-rebuild"
}
