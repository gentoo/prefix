# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/faad2/faad2-2.7.ebuild,v 1.8 2009/08/31 19:22:39 ranger Exp $

EAPI=2
inherit autotools eutils

DESCRIPTION="AAC audio decoding library"
HOMEPAGE="http://www.audiocoding.com/faad2.html"
SRC_URI="mirror://sourceforge/faac/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="digitalradio"

src_prepare() {
	sed -i -e 's:iquote :I:' libfaad/Makefile.am || die "sed failed"
	eautoreconf
}

src_configure() {
	econf \
		$(use_with digitalradio drm) \
		--without-xmms
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README README.linux TODO
}
