# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/squeak/squeak-3.9.7.ebuild,v 1.3 2007/02/06 08:57:22 genone Exp $

EAPI="prefix"

inherit base versionator fixheadtails eutils

MY_PV=$(replace_version_separator 2 '-')
DESCRIPTION="Highly-portable Smalltalk-80 implementation"
HOMEPAGE="http://www.squeak.org/"
SRC_URI="http://squeakvm.org/unix/release/Squeak-${MY_PV}.src.tar.gz"
LICENSE="Apple"
SLOT="0"
KEYWORDS="~ppc-macos"
IUSE="X mmx threads iconv"

DEPEND="
	X? ( || ( ( x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXt )
	virtual/x11 ) )"
RDEPEND="${DEPEND}
	virtual/squeak-image"

S="${WORKDIR}/Squeak-${MY_PV}"

src_unpack() {
	base_src_unpack
	epatch "${FILESDIR}"/${P}-no-cflag-injection.patch
	cd ${S}
	ht_fix_all
	cd "${S}"/platforms/unix/config
	# eautoreconf/eautoconf doesn't work, the packge uses some non-standard
	# stuff, so sed out what we don't like here manually
	sed -i -e 's/ac_optflags=.*$//g' configure
}

src_compile() {
	local myconf=""
	use X || myconf="--without-x"
	use mmx && myconf="${myconf} --enable-mpg-mmx"
	use threads && myconf="${myconf} --enable-mpg-pthread"
	use iconv || myconf="${myconf} --disable-iconv"
	cd ${S}
	mkdir build
	cd build
	../platforms/unix/config/configure \
		--prefix="${EPREFIX}"/usr \
		--infodir="${EPREFIX}"/usr/share/info \
		--mandir="${EPREFIX}"/usr/share/man \
		${myconf} || die "configure failed"
		#--with-ffi=x86-sysv \
	emake || die
}

src_install() {
	cd ${S}/build
	make ROOT="${D}" docdir="${EPREFIX}"/usr/share/doc/${PF} install || die
	exeinto /usr/lib/squeak
	doexe inisqueak
	dosym /usr/lib/squeak/inisqueak /usr/bin/inisqueak
}

pkg_postinst() {
	elog "Run 'inisqueak' to get a private copy of the squeak image."
}
