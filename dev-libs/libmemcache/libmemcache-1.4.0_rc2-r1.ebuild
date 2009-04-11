# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libmemcache/libmemcache-1.4.0_rc2-r1.ebuild,v 1.2 2008/10/10 08:53:01 robbat2 Exp $

inherit toolchain-funcs autotools

MY_PV="${PV/_rc/.rc}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="C API for memcached"
HOMEPAGE="http://people.freebsd.org/~seanc/libmemcache/"
SRC_URI="http://people.freebsd.org/~seanc/libmemcache/${MY_P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

RDEPEND=""

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	rm -rf test/unit
	sed -i -e '/DIR/s,unit,,g' test/Makefile.am
	sed -i \
		-e 's,test/unit/Makefile,,g' \
		-e '/^CFLAGS=.*Wall.*pipe/s,-Wall,${CFLAGS} -Wall,g' \
		-e '/^OPTIMIZE=/d' \
		-e '/^PROFILE=/d' \
		configure.ac
	eautoreconf
}

src_compile() {
	econf || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "emake install failed"
	dodoc ChangeLog
}
