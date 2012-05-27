# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-p2p/transmission/transmission-2.52.ebuild,v 1.1 2012/05/24 01:55:29 ssuominen Exp $

EAPI=4
LANGS="en es kk lt pt_BR ru"

unset _live_inherits

if [[ ${PV} == *9999* ]]; then
	ESVN_REPO_URI="svn://svn.transmissionbt.com/Transmission/trunk"
	_live_inherits=subversion
else
	SRC_URI="http://download.transmissionbt.com/${PN}/files/${P}.tar.xz"
	#KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~x86 ~x86-fbsd"
fi

inherit autotools eutils fdo-mime gnome2-utils qt4-r2 ${_live_inherits}

DESCRIPTION="A Fast, Easy and Free BitTorrent client"
HOMEPAGE="http://www.transmissionbt.com/"

LICENSE="GPL-2 MIT"
SLOT=0
IUSE="ayatana gtk lightweight qt4 xfs"

RDEPEND="
	>=dev-libs/libevent-2.0.10
	dev-libs/openssl:0
	net-libs/libnatpmp
	>=net-libs/miniupnpc-1.6.20120509
	>=net-misc/curl-7.16.3[ssl]
	sys-libs/zlib
	gtk? (
		>=dev-libs/dbus-glib-0.98
		>=dev-libs/glib-2.28
		>=x11-libs/gtk+-3.2:3
		ayatana? ( >=dev-libs/libappindicator-0.4.90:3 )
		)
	qt4? (
		x11-libs/qt-core:4
		x11-libs/qt-gui:4[dbus]
		)"

DEPEND="${RDEPEND}
	dev-util/intltool
	virtual/pkgconfig
	sys-devel/gettext
	virtual/os-headers
	xfs? ( sys-fs/xfsprogs )"

REQUIRED_USE="ayatana? ( gtk )"

DOCS="AUTHORS NEWS qt/README.txt"

pkg_setup() {
	enewgroup ${PN}
	enewuser ${PN} -1 -1 -1 ${PN}
}

src_unpack() {
	if [[ ${PV} == *9999* ]]; then
		subversion_src_unpack
	else
		default
	fi
}

src_prepare() {
	if [[ ${PV} == *9999* ]]; then
		subversion_src_prepare
		./update-version-h.sh
	fi

	sed -i -e '/CFLAGS/s:-ggdb3::' configure.ac
	use ayatana || sed -i -e '/^LIBAPPINDICATOR_MINIMUM/s:=.*:=9999:' configure.ac

	# http://trac.transmissionbt.com/ticket/4324
	sed -i -e 's|noinst\(_PROGRAMS = $(TESTS)\)|check\1|' lib${PN}/Makefile.am || die

	# http://bugs.gentoo.org/400929 ->
	# http://trac.transmissionbt.com/ticket/4915 ->
	# http://github.com/bittorrent/libutp/issues/35
	if ! grep -qs include.*netinet.*in.h third-party/libutp/utp.h; then
		epatch "${FILESDIR}"/${PN}-2.51-fbsd.patch
	fi

	eautoreconf

	if use qt4; then
		cat <<-EOF > "${T}"/${PN}-magnet.protocol
		[Protocol]
		exec=${PN}-qt '%u'
		protocol=magnet
		Icon=${PN}
		input=none
		output=none
		helper=true
		listing=
		reading=false
		writing=false
		makedir=false
		deleting=false
		EOF
	fi
}

src_configure() {
	export ac_cv_header_xfs_xfs_h=$(usex xfs)

	econf \
		--enable-external-natpmp \
		$(use_enable lightweight) \
		$(use_with gtk)

	if use qt4; then
		pushd qt >/dev/null
		eqmake4 qtr.pro
		popd >/dev/null
	fi
}

src_compile() {
	emake

	if use qt4; then
		pushd qt >/dev/null
		emake

		local l
		for l in ${LANGS}; do
			if use linguas_${l}; then
				lrelease translations/${PN}_${l}.ts
			fi
		done
		popd >/dev/null
	fi
}

src_install() {
	default

	rm -f "${ED}"/usr/share/${PN}/web/LICENSE

	newinitd "${FILESDIR}"/${PN}-daemon.initd.8 ${PN}-daemon
	newconfd "${FILESDIR}"/${PN}-daemon.confd.3 ${PN}-daemon

	keepdir /var/{${PN}/{config,downloads},log/${PN}}
	fowners -R ${PN}:${PN} /var/{${PN}/{,config,downloads},log/${PN}}

	if use qt4; then
		pushd qt >/dev/null
		emake INSTALL_ROOT="${ED}"/usr install

		domenu ${PN}-qt.desktop

		local res
		for res in 16 22 24 32 48; do
			insinto /usr/share/icons/hicolor/${res}x${res}/apps
			newins icons/hicolor_apps_${res}x${res}_${PN}.png ${PN}-qt.png
		done

		insinto /usr/share/kde4/services
		doins "${T}"/${PN}-magnet.protocol

		insinto /usr/share/qt4/translations
		local l
		for l in ${LANGS}; do
			if use linguas_${l}; then
				doins translations/${PN}_${l}.qm
			fi
		done
		popd >/dev/null
	fi
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update

	elog "If you use ${PN}-daemon, please, set 'rpc-username' and"
	elog "'rpc-password' (in plain text, ${PN}-daemon will hash it on"
	elog "start) in settings.json file located at /var/${PN}/config or"
	elog "any other appropriate config directory."
	elog
	elog "Since µTP is enabled by default, ${PN} needs large kernel buffers for"
	elog "the UDP socket. You can append following lines into /etc/sysctl.conf:"
	elog " net.core.rmem_max = 4194304"
	elog " net.core.wmem_max = 1048576"
	elog "and run sysctl -p"
}

pkg_postrm() {
	fdo-mime_desktop_database_update
	gnome2_icon_cache_update
}
