# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/taglib/taglib-1.6.1-r1.ebuild,v 1.1 2009/12/15 00:27:20 abcd Exp $

EAPI=2
inherit cmake-utils

DESCRIPTION="A library for reading and editing audio meta data"
HOMEPAGE="http://developer.kde.org/~wheeler/taglib.html"
SRC_URI="http://developer.kde.org/~wheeler/files/src/${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-solaris"
SLOT="0"
IUSE="+asf debug examples +mp4 static-libs test"

DEPEND="
	dev-util/pkgconfig
	test? ( dev-util/cppunit )
"
RDEPEND=""

PATCHES=(
	"${FILESDIR}"/${P}-install-examples.patch
)

DOCS="AUTHORS NEWS"

src_configure() {
	# prefix: do not "invent" lib64 (--disable-libsuffix) 
	mycmakeargs=(
		$(cmake-utils_use_enable static-libs STATIC)
		$(cmake-utils_use_build examples)
		$(cmake-utils_use_with asf)
		$(cmake-utils_use_with mp4)
		$(cmake-utils_use_enable !prefix libsuffix)
	)

	cmake-utils_src_configure
}

pkg_postinst() {
	if ! use asf; then
		elog "You've chosen to disable the asf use flag, thus taglib won't include"
		elog "support for Microsoft's 'advanced systems format' media container"
	fi
	if ! use mp4; then
		elog "You've chosen to disable the mp4 use flag, thus taglib won't include"
		elog "support for the MPEG-4 part 14 / MP4 media container"
	fi
}
