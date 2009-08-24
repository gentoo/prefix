# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/squeak/squeak-3.10.ebuild,v 1.3 2009/08/24 04:29:07 vostorga Exp $

inherit base fixheadtails eutils toolchain-funcs

MY_PV="${PV}-1"

DESCRIPTION="Highly-portable Smalltalk-80 implementation"
HOMEPAGE="http://www.squeak.org/"
SRC_URI="http://ftp.squeak.org/${PV}/unix-linux/Squeak-${MY_PV}.src.tar.gz
		mirror://gentoo/${P}-glibc210.patch.bz2"
LICENSE="Apple"
SLOT="0"
KEYWORDS="~ppc-macos"
IUSE="X mmx threads iconv opengl"

DEPEND="X? ( x11-libs/libX11 x11-libs/libXext x11-libs/libXt )
	opengl? ( virtual/opengl )"
RDEPEND="${DEPEND}
	virtual/squeak-image"

S="${WORKDIR}/Squeak-${MY_PV}"

src_unpack() {
	base_src_unpack
	cd "${S}"
	ht_fix_all
	einfo "Patch for inisqueak"
	sed -i s/\${MAJOR}/39/ "${S}/platforms/unix/config/inisqueak.in"
	# ht_fix_all doesn't catch this because there's no number
	sed -i -e 's/tail +/tail -n +/' platforms/unix/config/inisqueak.in
	sed -i s/-Werror// "${S}/platforms/unix/vm-display-fbdev/Makefile.in"
	cd "${WORKDIR}"
	epatch ${P}-glibc210.patch
}

src_compile() {
	local myconf=""
	use X || myconf="--without-x --without-npsqueak"
	use mmx && myconf="${myconf} --enable-mpg-mmx"
	use threads && myconf="${myconf} --enable-mpg-pthread"
	use opengl || myconf="${myconf} --without-gl"
	use iconv || myconf="${myconf} --disable-iconv"
	cd "${S}"
	mkdir build
	cd build
	../platforms/unix/config/configure \
		--prefix="${EPREFIX}"/usr \
		--infodir="${EPREFIX}"/usr/share/info \
		--mandir="${EPREFIX}"/usr/share/man \
		${myconf} CC="$(tc-getCC)" LD="$(tc-getLD)" || die "configure failed"
	emake CC="$(tc-getCC)" LD="$(tc-getLD)" || die
}

src_install() {
	cd "${S}/build"
	make ROOT="${D}" docdir="${EPREFIX}/usr/share/doc/${PF}" install || die
	exeinto /usr/lib/squeak
	doexe inisqueak
	dosym /usr/lib/squeak/inisqueak /usr/bin/inisqueak
}

pkg_postinst() {
	elog "Run 'inisqueak' to get a private copy of the squeak image."
}
