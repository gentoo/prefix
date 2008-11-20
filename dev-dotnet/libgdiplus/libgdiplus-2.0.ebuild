# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-dotnet/libgdiplus/libgdiplus-2.0.ebuild,v 1.1 2008/11/19 22:35:29 loki_val Exp $

EAPI="prefix"

inherit base eutils flag-o-matic toolchain-funcs

DESCRIPTION="Library for using System.Drawing with mono"
HOMEPAGE="http://www.go-mono.com/"
SRC_URI="http://www.go-mono.com/sources/${PN}/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="exif gif jpeg tiff"

RDEPEND=">=dev-libs/glib-2.6
		>=media-libs/freetype-2
		>=media-libs/fontconfig-2
		media-libs/libpng
		x11-libs/libXrender
		x11-libs/libX11
		x11-libs/libXt
		x11-libs/cairo
		exif? ( media-libs/libexif )
		gif? ( >=media-libs/giflib-4.1.3 )
		jpeg? ( media-libs/jpeg )
		tiff? ( media-libs/tiff )"
DEPEND="${RDEPEND}
		>=dev-util/pkgconfig-0.19"

RESTRICT="test"

PATCHES=( "${FILESDIR}/${PN}-1.2.5-imglibs.patch" )

pkg_setup() {
	if ! built_with_use x11-libs/cairo X; then
		eerror "you need to compile x11-libs/cairo with X USE flag enabled"
		die "missing X USE flag on x11-libs/cairo"
	fi
}

src_compile() {
	if [[ "$(gcc-major-version)" -gt "3" ]] || \
	   ( [[ "$(gcc-major-version)" -eq "3" ]] && [[ "$(gcc-minor-version)" -gt "3" ]] )
	then
		append-flags -fno-inline-functions
	fi

	# Disable glitz support as libgdiplus does not use it, and it causes errors
	econf	--disable-glitz          \
		--disable-dependency-tracking \
		--with-cairo=system \
		$(use_with exif libexif) \
		$(use_with gif libgif)   \
		$(use_with jpeg libjpeg) \
		$(use_with tiff libtiff) || die "configure failed"

	emake || die "compile failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
	dodoc AUTHORS ChangeLog NEWS README
}
