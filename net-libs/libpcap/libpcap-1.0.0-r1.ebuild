# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-libs/libpcap/libpcap-1.0.0-r1.ebuild,v 1.5 2009/05/12 10:09:41 loki_val Exp $

inherit autotools eutils multilib toolchain-funcs

DESCRIPTION="A system-independent library for user-level network packet capture"
HOMEPAGE="http://www.tcpdump.org/"
SRC_URI="http://www.tcpdump.org/release/${P}.tar.gz
	http://www.jp.tcpdump.org/release/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="ipv6 bluetooth"

RDEPEND="!virtual/libpcap
	bluetooth? ( || ( net-wireless/bluez net-wireless/bluez-libs ) )"
DEPEND="${RDEPEND}
	sys-devel/flex"
PROVIDE="virtual/libpcap"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${P}-cross-linux.patch"
	epatch "${FILESDIR}/${P}-install-bindir.patch"
	epatch "${FILESDIR}/${P}-install-headers.patch"
	epatch "${FILESDIR}/${P}-optional-bluetooth.patch"
	epatch "${FILESDIR}/${P}-LDFLAGS.patch"
	eautoreconf
}

src_compile() {
	econf $(use_enable ipv6) \
		$(use_enable bluetooth)
	emake all shared || die "compile problem"
}

src_install() {
	emake DESTDIR="${D}" install install-shared || die "emake install failed"

	dosym libpcap$(get_libname ${PV:0:5}) /usr/$(get_libdir)/libpcap$(get_libname 1)
	dosym libpcap$(get_libname ${PV:0:5}) /usr/$(get_libdir)/libpcap$(get_libname)

	# We need this to build pppd on G/FBSD systems
	if [[ "${USERLAND}" == "BSD" ]]; then
		insinto /usr/include
		doins pcap-int.h || die "failed to install pcap-int.h"
	fi

	# We are not installing README.{Win32,aix,hpux,tru64} (bug 183057)
	dodoc CREDITS CHANGES VERSION TODO README{,.dag,.linux,.macosx,.septel}
}
