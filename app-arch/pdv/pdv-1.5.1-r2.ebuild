# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/pdv/pdv-1.5.1-r2.ebuild,v 1.10 2010/12/02 16:27:02 flameeyes Exp $

EAPI=1

inherit eutils autotools flag-o-matic

DESCRIPTION="build a self-extracting and self-installing binary package"
HOMEPAGE="http://sourceforge.net/projects/pdv"
SRC_URI="mirror://sourceforge/pdv/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86-interix ~x86-linux ~ppc-macos"
IUSE="X"

DEPEND="X? ( >=x11-libs/openmotif-2.3:0
	>=x11-libs/libX11-1.0.0
	>=x11-libs/libXt-1.0.0
	>=x11-libs/libXext-1.0.0
	>=x11-libs/libXp-1.0.0 )"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# fix a size-of-variable bug
	epatch "${FILESDIR}"/${P}-opt.patch
	# fix a free-before-use bug
	epatch "${FILESDIR}"/${P}-early-free.patch
	# fix a configure script bug
	epatch "${FILESDIR}"/${P}-x-config.patch
	# fix default args bug from assuming 'char' is signed
	epatch "${FILESDIR}"/${P}-default-args.patch
	# prevent pre-stripped binaries
	epatch "${FILESDIR}"/${P}-no-strip.patch

	# re-build configure script since patch was applied to configure.in
	cd "${S}"/X11
	eautoreconf
}

src_compile() {
	if [[ ${CHOST} == *-interix* ]]; then
		# seems like a bug in openmotiv build on interix, but i can't find it.
		# if this is missing i get unresolved libiconv_* symbols for libXm.so
		use X && append-libs -liconv
	fi

	local myconf=""
	use X || myconf="--without-x" # configure script is broken, cant use use_with
	econf ${myconf} || die
	emake || die
}

src_install() {
	dobin pdv pdvmkpkg || die
	doman pdv.1 pdvmkpkg.1
	if use X ; then
		dobin X11/xmpdvmkpkg || die
		doman xmpdvmkpkg.1 || die
	fi
	dodoc AUTHORS ChangeLog NEWS README pdv.lsm
}
