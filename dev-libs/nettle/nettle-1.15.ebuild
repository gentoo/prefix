# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/nettle/nettle-1.15.ebuild,v 1.6 2007/12/11 10:03:54 vapier Exp $

EAPI="prefix"

inherit eutils autotools

DESCRIPTION="cryptographic library that is designed to fit easily in any context"
HOMEPAGE="http://www.lysator.liu.se/~nisse/nettle/"
SRC_URI="http://www.lysator.liu.se/~nisse/archive/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="gmp ssl"

DEPEND="gmp? ( dev-libs/gmp )
	ssl? ( dev-libs/openssl )
	!<dev-libs/lsh-1.4.3-r1"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/${PN}-1.14-make-as-needed.patch"
	epatch "${FILESDIR}/${P}-link-darwin.patch"
	sed -i \
		-e '/CFLAGS/s:-ggdb3::' \
		configure.ac || die
	eautoreconf
}

src_compile() {
	econf \
		--enable-shared \
		$(use_enable ssl openssl) \
		$(use_enable gmp public-key) \
		|| die
	emake || die
}

src_test() {
	# Darwin uses DYLD_LIBRARY_PATH instead
	[[ ${CHOST} == *-darwin* ]] &&
		sed -i \
			-e 's/\(LD_LIBRARY_PATH\)/DY\1/' \
			{examples,testsuite}/Makefile
	emake check || die
}

src_install() {
	make DESTDIR="${D}" install  || die
	dodoc AUTHORS ChangeLog NEWS README
}
