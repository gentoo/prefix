# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/memcached/memcached-1.3.3.ebuild,v 1.2 2009/04/13 02:28:41 robbat2 Exp $

inherit eutils autotools

MY_PV="${PV/_rc/-rc}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="High-performance, distributed memory object caching system"
HOMEPAGE="http://code.google.com/p/memcached/"
SRC_URI="http://memcached.googlecode.com/files/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="nptl test"

RDEPEND=">=dev-libs/libevent-1.4
		 dev-lang/perl"
DEPEND="${RDEPEND}
		test? ( virtual/perl-Test-Harness >=dev-perl/Cache-Memcached-1.24 )"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-1.2.2-fbsd.patch"
	sed -i -e 's,-Werror,,g' configure.ac || die "sed failed"
	eautoreconf
}

src_compile() {
	econf $(use_enable nptl threads)
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dobin scripts/memcached-tool

	dodoc AUTHORS ChangeLog NEWS README TODO doc/{CONTRIBUTORS,*.txt}

	newconfd "${FILESDIR}"/1.2.6/conf memcached
	newinitd "${FILESDIR}"/1.2.6/init memcached
}

pkg_postinst() {
	enewuser memcached -1 -1 /dev/null daemon

	elog "With this version of Memcached Gentoo now supports multiple instances."
	elog "To enable this you must create a symlink in /etc/init.d/ for each instance"
	elog "to /etc/init.d/memcached and create the matching conf files in /etc/conf.d/"
	elog "Please see Gentoo bug #122246 for more info"
}

src_test() {
	emake -j1 test || die "Failed testing"
}
