# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/flac/flac-1.2.1-r3.ebuild,v 1.9 2008/12/02 21:21:13 ranger Exp $

EAPI=1

inherit autotools eutils base

DESCRIPTION="free lossless audio encoder and decoder"
HOMEPAGE="http://flac.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="3dnow altivec +cxx debug doc ogg sse"

RDEPEND="ogg? ( >=media-libs/libogg-1.1.3 )"
DEPEND="${RDEPEND}
	x86? ( dev-lang/nasm )
	!elibc_uclibc? ( sys-devel/gettext )
	dev-util/pkgconfig"

PATCHES=( "${FILESDIR}/${P}-asneeded.patch"
	"${FILESDIR}/${P}-cflags.patch"
	"${FILESDIR}/${P}-asm.patch"
	"${FILESDIR}/${P}-dontbuild-tests.patch"
	"${FILESDIR}/${P}-dontbuild-examples.patch"
	"${FILESDIR}/${P}-gcc-4.3-includes.patch"
	"${FILESDIR}"/${P}-irix.patch )

src_unpack() {
	base_src_unpack
	cd "${S}"
	AT_M4DIR="m4" eautoreconf
}

src_compile() {
	local myconf
	[[ ${CHOST} == *-darwin* ]] && myconf="--disable-asm-optimizations"
	econf $(use_enable ogg) \
		$(use_enable sse) \
		$(use_enable 3dnow) \
		$(use_enable altivec) \
		$(use_enable debug) \
		$(use_enable cxx cpplibs) \
		--disable-examples \
		--disable-doxygen-docs \
		--disable-dependency-tracking \
		--disable-xmms-plugin ${myconf}

	emake || die "emake failed."
}

src_test() {
	if [ $UID != 0 ] ; then
		emake check || die "tests failed"
	else
		ewarn "Tests will fail if ran as root, skipping."
	fi
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
