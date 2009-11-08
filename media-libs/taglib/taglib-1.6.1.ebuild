# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/taglib/taglib-1.6.1.ebuild,v 1.1 2009/11/05 10:50:19 jmbsvicetto Exp $

EAPI=2
inherit base

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

src_configure() {
	# prefix: do not "invent" lib64 (--disable-libsuffix) 
	econf \
		$(use_enable asf) \
		$(use_enable debug) \
		$(use_enable mp4) \
		$(use_enable static-libs static) \
		$(use_enable !prefix libsuffix)
}

src_compile() {
	base_src_compile

	if use examples; then
		emake examples || die "emake examples failed"
	fi
}

src_install() {
	base_src_install

	dodoc AUTHORS NEWS || die "dodoc failed"
	dohtml doc/* || die "dohtml failed"

	if use examples; then
		cd examples && emake DESTDIR="${D}" install || die "emake examples install failed"
	fi
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
