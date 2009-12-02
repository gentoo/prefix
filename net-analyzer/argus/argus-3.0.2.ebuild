# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-analyzer/argus/argus-3.0.2.ebuild,v 1.1 2009/11/30 16:01:56 pva Exp $

EAPI="2"

inherit eutils autotools

DESCRIPTION="network Audit Record Generation and Utilization System"
HOMEPAGE="http://www.qosient.com/argus/"
SRC_URI="http://qosient.com/argus/dev/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="debug tcpd"

#	sasl? ( >=dev-libs/cyrus-sasl-2.1.22 )
RDEPEND="net-libs/libpcap
	tcpd? ( >=sys-apps/tcp-wrappers-7.6 )"

DEPEND="${RDEPEND}
	>=sys-devel/bison-1.28
	>=sys-devel/flex-2.4.6"

src_prepare() {
	sed -e 's:/etc/argus.conf:/etc/argus/argus.conf:' \
		-i argus/argus.c \
		-i support/Config/argus.conf \
		-i man/man8/argus.8 \
		-i man/man5/argus.conf.5 || die

	sed -e 's:#\(ARGUS_SETUSER_ID=\).*:\1argus:' \
		-e 's:#\(ARGUS_SETGROUP_ID=\).*:\1argus:' \
		-e 's:\(#ARGUS_CHROOT_DIR=\).*:\1/var/lib/argus:' \
			-i support/Config/argus.conf || die

	epatch "${FILESDIR}/${PN}-disable-tcp-wrappers-automagic.patch"
	eautoreconf
}

src_configure() {
	use debug && touch .debug # enable debugging
	#	$(use_with sasl) \
	econf \
		$(use_with tcpd wrappers)
}

src_install () {
	doman man/man5/* man/man8/*
	dosbin bin/argus{,bug} || die

	dodoc ChangeLog CREDITS README || die

	insinto /etc/argus
	doins support/Config/argus.conf || die

	newinitd "${FILESDIR}/argus.initd" argus || die
	dodir /var/lib/argus
}

pkg_preinst() {
	enewgroup argus
	enewuser argus -1 -1 /var/lib/argus argus
}

pkg_postinst() {
	elog "Note, if you modify ARGUS_DAEMON value in argus.conf it's quite"
	elog "possible that init script will fail to work."
}
