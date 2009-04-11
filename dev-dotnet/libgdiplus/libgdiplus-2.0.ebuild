# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/libgdiplus/libgdiplus-2.0.ebuild,v 1.4 2009/04/04 14:04:29 maekke Exp $

EAPI=2

inherit flag-o-matic toolchain-funcs

DESCRIPTION="Library for using System.Drawing with mono"
HOMEPAGE="http://www.go-mono.com/"
SRC_URI="http://www.go-mono.com/sources/${PN}/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE=""

RDEPEND=">=dev-libs/glib-2.6
		>=media-libs/freetype-2
		>=media-libs/fontconfig-2
		media-libs/libpng
		x11-libs/libXrender
		x11-libs/libX11
		x11-libs/libXt
		x11-libs/cairo[X]
		media-libs/libexif
		>=media-libs/giflib-4.1.3
		media-libs/jpeg
		media-libs/tiff"
DEPEND="${RDEPEND}
		>=dev-util/pkgconfig-0.19"

RESTRICT="test"

src_configure() {
	if [[ "$(gcc-major-version)" -gt "3" ]] || \
	   ( [[ "$(gcc-major-version)" -eq "3" ]] && [[ "$(gcc-minor-version)" -gt "3" ]] )
	then
		append-flags -fno-inline-functions
	fi

	# Disable glitz support as libgdiplus does not use it, and it causes errors
	econf	--disable-dependency-tracking	\
		--with-cairo=system		\
		|| die "configure failed"
}

src_compile() {
	emake || die "compile failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS ChangeLog NEWS README
}
