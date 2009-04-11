# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/madplay/madplay-0.15.2b-r1.ebuild,v 1.11 2008/01/16 18:31:36 grobian Exp $

inherit eutils autotools

DESCRIPTION="The MAD audio player"
HOMEPAGE="http://www.underbit.com/products/mad/"
SRC_URI="mirror://sourceforge/mad/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="debug nls esd alsa"

#	~media-libs/libmad-${PV}
#	~media-libs/libid3tag-${PV}
# This version uses the previous libs... the only change is in handling lame encoded mp3s...
# See http://sourceforge.net/project/shownotes.php?group_id=12349&release_id=219475

RDEPEND="esd? ( media-sound/esound )
	~media-libs/libmad-0.15.1b
	alsa? ( media-libs/alsa-lib )
	~media-libs/libid3tag-0.15.1b"
DEPEND="${RDEPEND}
	nls? ( >=sys-devel/gettext-0.11.2 )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	eautoreconf # need new libtool for interix
	epunt_cxx #74499
	epatch "${FILESDIR}/${PN}-macos.patch"
}

src_compile() {
	# configure will bail out if both esd and alsa are enabled
	local myconf
	use alsa && myconf="--with-alsa --without-esd"
	use esd && myconf="--without-alsa --with-esd"
	use alsa || use esd || myconf="--without-alsa --without-esd"

	econf \
		$(use_enable nls) \
		$(use_enable debug debugging) \
		${myconf} \
		|| die "configure failed"
	emake || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc CHANGES CREDITS README TODO VERSION
}
