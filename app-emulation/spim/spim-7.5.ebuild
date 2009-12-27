# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/spim/spim-7.5.ebuild,v 1.1 2009/12/22 19:53:09 spatz Exp $

EAPI="2"

inherit eutils toolchain-funcs

DESCRIPTION="MIPS Simulator"
HOMEPAGE="http://www.cs.wisc.edu/~larus/spim.html"
SRC_URI="http://www.cs.wisc.edu/~larus/SPIM/${P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="X"

RDEPEND="X? ( x11-libs/libXaw
		x11-libs/libXp )"
DEPEND="${RDEPEND}
	X? ( x11-misc/imake
		x11-proto/xproto )
	>=sys-apps/sed-4
	sys-devel/bison"

src_prepare() {
	# fix bugs 240005 and 243588
	epatch "${FILESDIR}/${P}-respect_env.patch"
	tc-export CC

	# Fix documentation files
	cd "${S}/Documentation"
	mv spim.man spim.1
	mv xspim.man xspim.1
}

src_configure() {
	cd "${S}/spim"
	./Configure || die "Configure Failed!"

	if use X; then
		cd "${S}/xspim"
		./Configure || die "Configure Failed!"
	fi
}

src_compile() {
	cd "${S}/spim"
	emake || die

	if use X; then
		cd "${S}/xspim"
		emake -j1 xspim || die
	fi
}

src_install() {
	dodir /var/lib/spim || die
	dodoc README VERSION ChangeLog || die

	cd "${S}/spim"
	emake DESTDIR="${D}" install || die "Unable to install spim"

	if use X; then
		cd "${S}/xspim"
		emake DESTDIR="${D}" install || die "Unable to install xspim"

		doman "${S}/Documentation/xspim.1"
	fi

	cd "${S}/Documentation"
	doman spim.1 || die

	dohtml SPIM.html || die
	dodoc BLURB || die
}

src_test() {
	cd "${S}/spim"
	make test || die "Failed to pass tests!"
}
