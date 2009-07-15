# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libmp4v2/libmp4v2-1.9.1.ebuild,v 1.1 2009/07/14 18:34:16 ssuominen Exp $

EAPI=2

DESCRIPTION="Functions for accessing ISO-IEC:14496-1:2001 MPEG-4 standard"
HOMEPAGE="http://code.google.com/p/mp4v2"
SRC_URI="http://mp4v2.googlecode.com/files/${P/lib}.tar.bz2"

LICENSE="MPL-1.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="utils"

RDEPEND=""
DEPEND="utils? ( sys-apps/help2man )
	!media-video/mpeg4ip
	sys-apps/sed"

S=${WORKDIR}/${P/lib}

src_configure() {
	econf \
		$(use_enable utils util) \
		--disable-dependency-tracking
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc doc/*.txt README
}
