# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/memcached/memcached-1.3.3-r2.ebuild,v 1.2 2009/05/26 01:42:49 jer Exp $

inherit eutils autotools flag-o-matic

MY_PV="${PV/_rc/-rc}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="High-performance, distributed memory object caching system"
HOMEPAGE="http://code.google.com/p/memcached/"
SRC_URI="http://memcached.googlecode.com/files/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="test slabs-reassign"

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
	use slabs-reassign && append-flags -DALLOW_SLABS_REASSIGN
}

src_compile() {
	econf
	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dobin scripts/memcached-tool

	dodoc AUTHORS ChangeLog NEWS README TODO doc/{CONTRIBUTORS,*.txt}

	newconfd "${FILESDIR}"/1.3.3/conf memcached
	newinitd "${FILESDIR}"/1.3.3/init memcached
}

pkg_postinst() {
	enewuser memcached -1 -1 /dev/null daemon

	elog "With this version of Memcached Gentoo now supports multiple instances."
	elog "To enable this you should create a symlink in /etc/init.d/ for each instance"
	elog "to /etc/init.d/memcached and create the matching conf files in /etc/conf.d/"
	elog "Please see Gentoo bug #122246 for more info"
}

src_test() {
	emake -j1 test || die "Failed testing"
}
