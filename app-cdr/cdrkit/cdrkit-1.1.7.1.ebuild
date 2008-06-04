# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/app-cdr/cdrkit/cdrkit-1.1.7.1.ebuild,v 1.2 2008/04/18 14:42:10 beandog Exp $

EAPI="prefix"

inherit eutils toolchain-funcs flag-o-matic

DESCRIPTION="A suite of programs for recording CDs and DVDs, blanking CD-RW media, creating ISO-9660 filesystem images, extracting audio CD data, and more."
HOMEPAGE="http://cdrkit.org/"
SRC_URI="http://cdrkit.org/releases/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="hfs unicode kernel_linux kernel_FreeBSD"

DEPEND=">=dev-util/cmake-2.4
	!app-cdr/cdrtools
	kernel_linux? ( sys-libs/libcap )
	unicode? ( virtual/libiconv )
	hfs? ( sys-apps/file )"
RDEPEND="unicode? ( virtual/libiconv )
	kernel_linux? ( sys-libs/libcap )"

PROVIDE="virtual/cdrtools"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# this might break others, since it removed -lrt from the
	# link line.
	[[ ${CHOST} == *-interix* ]] && epatch "${FILESDIR}"/${P}-interix.patch
}

src_compile() {
	[[ ${CHOST} == *-interix* ]] && append-flags -D_ALL_SOURCE

	cmake \
		-DCMAKE_C_COMPILER=$(type -P $(tc-getCC)) \
		-DCMAKE_C_FLAGS="${CFLAGS}" \
		-DCMAKE_CXX_COMPILER=$(type -P $(tc-getCXX)) \
		-DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
		-DCMAKE_BUILD_TYPE=None \
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr" \
		|| die "cmake failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dosym /usr/bin/wodim /usr/bin/cdrecord
	dosym /usr/bin/genisoimage /usr/bin/mkisofs
	dosym /usr/bin/icedax /usr/bin/cdda2wav
	dosym /usr/bin/readom /usr/bin/readcd
	dosym /usr/share/man/man1/wodim.1.bz2 /usr/share/man/man1/cdrecord.1.bz2
	dosym /usr/share/man/man1/genisoimage.1.bz2 /usr/share/man/man1/mkisofs.1.bz2
	dosym /usr/share/man/man1/icedax.1.bz2 /usr/share/man/man1/cdda2wav.1.bz2
	dosym /usr/share/man/man1/readom.1.bz2 /usr/share/man/man1/readcd.1.bz2

	cd "${S}"
	dodoc ABOUT Changelog FAQ FORK START TODO VERSION

	cd "${S}"/doc/READMEs
	dodoc README*

	cd "${S}"/doc/wodim
	dodoc README*

	cd "${S}"/doc/genisoimage
	docinto genisoimage
	dodoc *

	cd "${S}"/doc/icedax
	docinto icedax
	dodoc FAQ Frontends HOWTOUSE NEEDED README TODO

	cd "${S}"/doc/plattforms
	docinto platforms
	dodoc README.{linux,parallel}

	cd "${S}"
	insinto /etc
	newins wodim/wodim.dfl wodim.conf
	newins netscsid/netscsid.dfl netscsid.conf

	cd "${S}"
	insinto /usr/include/scsilib
	doins include/*.h
	insinto /usr/include/scsilib/usal
	doins include/usal/*.h
	dosym /usr/include/scsilib/usal /usr/include/scsilib/scg
}
