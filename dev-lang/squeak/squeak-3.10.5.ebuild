# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/squeak/squeak-3.10.5.ebuild,v 1.1 2009/09/01 10:14:04 patrick Exp $

inherit base versionator fixheadtails eutils

MY_PV=$(replace_version_separator 2 '-')
DESCRIPTION="Highly-portable Smalltalk-80 implementation"
HOMEPAGE="http://www.squeak.org/"
SRC_URI="http://squeakvm.org/unix/release/Squeak-${MY_PV}.src.tar.gz"
LICENSE="Apple"
SLOT="0"
KEYWORDS="~ppc-macos"
IUSE="X mmx threads iconv"

DEPEND="X? ( x11-libs/libX11 x11-libs/libXext x11-libs/libXt )"
RDEPEND="${DEPEND}
	virtual/squeak-image"

S="${WORKDIR}/Squeak-${MY_PV}"

src_unpack() {
	base_src_unpack
	cd ${S}
	# patches to "fix" dprintf collision with glibc
	# see http://bugs.squeak.org/view.php?id=7331
	# and http://sisyphus.ru/srpm/Sisyphus/squeak-vm-sugar/patches/0
	epatch "${FILESDIR}"/squeak-vm-sugar-3.10.3-sugar-squeak-dprintf.patch
	epatch "${FILESDIR}"/squeak-dprintf.patch
	epatch "${FILESDIR}"/squeak-inisqueak.patch
	ht_fix_all
	# ht_fix_all doesn't catch this because there's no number
	sed -i -e 's/tail +/tail -n +/' platforms/unix/config/inisqueak.in
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
	emake || die
}

src_install() {
	cd ${S}/build
	make ROOT="${D}" docdir="${EPREFIX}/usr/share/doc/${PF}" install || die
	exeinto /usr/lib/squeak
	doexe inisqueak
	dosym /usr/lib/squeak/inisqueak /usr/bin/inisqueak
}

pkg_postinst() {
	elog "Run 'inisqueak' to get a private copy of the squeak image."
}
