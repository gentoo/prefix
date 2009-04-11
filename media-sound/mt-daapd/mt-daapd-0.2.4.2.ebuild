# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mt-daapd/mt-daapd-0.2.4.2.ebuild,v 1.5 2008/09/27 16:25:25 armin76 Exp $

inherit autotools eutils

DESCRIPTION="A multi-threaded implementation of Apple's DAAP server"
HOMEPAGE="http://www.mt-daapd.org"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="avahi vorbis"

RDEPEND="media-libs/libid3tag
	sys-libs/gdbm
	avahi? ( net-dns/avahi )
	!avahi? ( net-misc/mDNSResponder )
	vorbis? ( media-libs/libvorbis )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

pkg_setup() {
	local fail="Re-emerge net-dns/avahi with USE dbus."

	if use avahi && ! built_with_use net-dns/avahi dbus; then
		eerror "${fail}"
		die "${fail}"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"

	cp "${FILESDIR}"/${PN}.init.2 initd

	if use avahi; then
		sed -i -e 's:#USEHOWL need mDNSResponder:need avahi-daemon:' initd
	else
		sed -i -e 's:#USEHOWL ::' initd
	fi

	epatch "${FILESDIR}"/${PN}-0.2.3-sparc.patch
	epatch "${FILESDIR}"/${PN}-0.2.4.1-libsorder.patch
	epatch "${FILESDIR}"/${PN}-0.2.4.1-pidfile.patch
	epatch "${FILESDIR}"/${P}-maintainer-mode.patch
	eautoreconf
}

src_compile() {
	local myconf

	if use avahi; then
		myconf="--enable-avahi --disable-mdns"
	else
		myconf="--disable-avahi --enable-mdns"
	fi

	econf $(use_enable vorbis oggvorbis) \
		--disable-maintainer-mode \
		${myconf}

	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."

	insinto /etc
	newins contrib/mt-daapd.conf mt-daapd.conf.example
	doins contrib/mt-daapd.playlist

	newinitd initd ${PN}

	keepdir /var/cache/mt-daapd /etc/mt-daapd.d
	dodoc AUTHORS ChangeLog CREDITS NEWS README TODO
}

pkg_postinst() {
	einfo
	elog "You have to configure your mt-daapd.conf following"
	elog "/etc/mt-daapd.conf.example file."
	einfo

	if use vorbis; then
		einfo
		elog "You need to edit you extensions list in /etc/mt-daapd.conf"
		elog "if you want your mt-daapd to serve ogg files."
		einfo
	fi

	einfo
	elog "If you want to start more than one ${PN} service, symlink"
	elog "/etc/init.d/${PN} to /etc/init.d/${PN}.<name>, and it will"
	elog "load the data from /etc/${PN}.d/<name>.conf."
	elog "Make sure that you have different cache directories for them."
	einfo
}
