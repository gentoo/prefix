# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/flac/flac-1.2.1.ebuild,v 1.3 2007/09/20 19:46:10 drac Exp $

EAPI="prefix"

inherit autotools eutils libtool

DESCRIPTION="free lossless audio encoder and decoder"
HOMEPAGE="http://flac.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="3dnow altivec debug doc pic ogg sse"

RDEPEND="ogg? ( >=media-libs/libogg-1.1.2 )"
DEPEND="${RDEPEND}
	x86? ( dev-lang/nasm )
	sys-apps/gawk
	sys-devel/gettext
	doc? ( app-doc/doxygen )
	dev-util/pkgconfig"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# asneeded fails with libiconv on non glibc systems
	epatch "${FILESDIR}"/${P}-asneeded.patch
	# strip upstream forced optimizations
	epatch "${FILESDIR}"/${P}-cflags.patch
	AT_M4DIR="m4" eautoreconf
	elibtoolize
}

src_compile() {
	local myconf

	# fugly, fixme, x86 asm has text relocations..
	if use x86 && use pic; then
		myconf="--disable-asm-optimizations"
	fi

	econf $(use_enable ogg) \
		$(use_enable sse) \
		$(use_enable 3dnow) \
		$(use_enable altivec) \
		$(use_enable debug) \
		$(use_enable doc doxygen-docs) \
		--disable-dependency-tracking \
		--disable-xmms-plugin \
		${myconf} || die "econf failed."
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	use doc || rm -rf "${ED}"/usr/share/doc/${PN}*
	dodoc AUTHORS README
}

pkg_postinst() {
	ewarn "If you've upgraded from a previous version of flac, you may need to re-emerge"
	ewarn "packages that linked against flac by running revdep-rebuild"
}
