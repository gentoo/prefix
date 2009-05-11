# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-cdr/cdrkit/cdrkit-1.1.9-r1.ebuild,v 1.1 2009/05/07 20:55:51 ssuominen Exp $

inherit cmake-utils

DESCRIPTION="A set of tools for CD/DVD reading and recording, including cdrecord"
HOMEPAGE="http://cdrkit.org"
SRC_URI="http://cdrkit.org/releases/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-solaris"
IUSE="hfs unicode kernel_linux"

RDEPEND="unicode? ( virtual/libiconv )
	kernel_linux? ( sys-libs/libcap )"
DEPEND="${RDEPEND}
	!app-cdr/cdrtools
	hfs? ( sys-apps/file )"

PROVIDE="virtual/cdrtools"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# this might break others, since it removed -lrt from the
	# link line.
	[[ ${CHOST} == *-interix* ]] && epatch "${FILESDIR}"/${PN}-1.1.7-interix.patch
	[[ ${CHOST} == *-interix3* ]] && epatch "${FILESDIR}"/${PN}-1.1.8-interix3.patch
}

src_install() {
	cmake-utils_src_install

	local msuffix=$(ecompress --suffix)

	dosym wodim /usr/bin/cdrecord || die
	dosym genisoimage /usr/bin/mkisofs || die
	dosym icedax /usr/bin/cdda2wav || die
	dosym readom /usr/bin/readcd || die
	dosym wodim.1${msuffix} /usr/share/man/man1/cdrecord.1${msuffix}
	dosym genisoimage.1${msuffix} /usr/share/man/man1/mkisofs.1${msuffix}
	dosym icedax.1${msuffix} /usr/share/man/man1/cdda2wav.1${msuffix}
	dosym readom.1${msuffix} /usr/share/man/man1/readcd.1${msuffix}

	dodoc ABOUT Changelog FAQ FORK TODO doc/{PORTABILITY,WHY}

	for x in genisoimage plattforms wodim icedax; do
		docinto ${x}
		dodoc doc/${x}/*
	done

	insinto /etc
	newins wodim/wodim.dfl wodim.conf || die
	newins netscsid/netscsid.dfl netscsid.conf || die

	insinto /usr/include/scsilib
	doins include/*.h || die
	insinto /usr/include/scsilib/usal
	doins include/usal/*.h || die
	dosym usal /usr/include/scsilib/scg || die
}
