# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/x11vnc/x11vnc-0.9.3.ebuild,v 1.5 2008/05/03 14:40:39 rich0 Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="A VNC server for real X displays"
HOMEPAGE="http://www.karlrunge.com/x11vnc/"
SRC_URI="mirror://sourceforge/libvncserver/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"
IUSE="jpeg zlib threads ssl crypt v4l xinerama avahi system-libvncserver"

RDEPEND="system-libvncserver? ( >=net-libs/libvncserver-0.9.1 )
	zlib? ( sys-libs/zlib )
	jpeg? (	media-libs/jpeg )
	ssl? ( dev-libs/openssl )
	avahi? ( >=net-dns/avahi-0.6.4 )
	xinerama? ( x11-libs/libXinerama )
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libX11
	x11-libs/libXtst
	x11-libs/libXdamage
	x11-libs/libXext"

DEPEND="${RDEPEND}
	x11-libs/libXt
	xinerama? ( x11-proto/xineramaproto )
	x11-proto/inputproto
	x11-proto/trapproto
	x11-proto/recordproto
	x11-proto/xproto
	x11-proto/xextproto"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${P}-interix.patch
}

src_compile() {
	local myconf=""

	# we need to force threads on, because our system libvncserver gets build with thread support
	use system-libvncserver && myconf="--with-pthread"

	econf \
		$(use_with system-libvncserver) \
		$(use_with avahi) \
		$(use_with xinerama) \
		$(use_with ssl) \
		$(use_with ssl crypto) \
		$(use_with crypt) \
		$(use_with v4l) \
		$(use_with jpeg) \
		$(use_with zlib) \
		$(use_with threads pthread) \
		${myconf} \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"
	dodoc x11vnc/{ChangeLog,README}
}
