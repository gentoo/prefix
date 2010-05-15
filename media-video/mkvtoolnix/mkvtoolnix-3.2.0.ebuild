# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/mkvtoolnix/mkvtoolnix-3.2.0.ebuild,v 1.3 2010/03/18 13:03:03 spatz Exp $

EAPI="1"
inherit eutils wxwidgets flag-o-matic qt4 autotools

DESCRIPTION="Tools to create, alter, and inspect Matroska files"
HOMEPAGE="http://www.bunkus.org/videotools/mkvtoolnix"
SRC_URI="http://www.bunkus.org/videotools/mkvtoolnix/sources/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE="bzip2 debug doc flac lzo qt4 wxwidgets"

DEPEND=">=dev-libs/libebml-0.7.7
	>=media-libs/libmatroska-0.8.1
	media-libs/libogg
	media-libs/libvorbis
	dev-libs/expat
	sys-libs/zlib
	dev-libs/boost
	wxwidgets? ( x11-libs/wxGTK:2.8 )
	flac? ( media-libs/flac )
	bzip2? ( app-arch/bzip2 )
	lzo? ( dev-libs/lzo )
	qt4? ( x11-libs/qt-gui:4 )"
RDEPEND="${DEPEND}"

pkg_setup() {
	WX_GTK_VER="2.8"
	if use wxwidgets; then
		need-wxwidgets unicode
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	eautoreconf
}

src_compile() {
	use wxwidgets && myconf="--with-wx-config=${WX_CONFIG}"
	econf \
		$(use_enable lzo) \
		$(use_enable bzip2 bz2) \
		$(use_enable wxwidgets) \
		$(use_enable debug) \
		$(use_with flac) \
		$(use_enable qt4 qt) \
		${myconf} \
		--with-boost-regex=boost_regex \
		--with-boost-filesystem=boost_filesystem \
		--with-boost-system=boost_system \
		--with-boost="${EPREFIX}"/usr \
		--with-boost-libdir="${EPREFIX}"/usr/$(get_libdir)

	# Don't run strip while installing stuff, leave to portage the job.
	emake STRIP="true" || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" STRIP="true" install || die "make install failed"
	dodoc AUTHORS ChangeLog README TODO || die "dodoc failed"
	doman doc/man/*.1 || die "doman failed"

	if use doc; then
		dohtml doc/guide/en/mkvmerge-gui.html || die "dohtml failed"
		docinto html/images
		dohtml doc/guide/en/images/* || die "dohtml failed"
		docinto examples
		dodoc examples/* || die "dodoc failed"
	fi
}
