# Copyright 2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit autotools eutils

MY_PV=${PV#4.1_pre}

DESCRIPTION="Port of OpenBSD's free RCS release"
HOMEPAGE="http://chl.be/openrcs/"
SRC_URI="http://chl.be/openrcs/openrcs-${MY_PV}.tar.gz"
LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~x86-macos"
IUSE=""

RDEPEND="!app-text/rcs"
DEPEND=""

S=${WORKDIR}/${PN}

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-configure.ac.patch
	epatch "${FILESDIR}"/${PN}-u_long.patch
	epatch "${FILESDIR}"/${PN}-warnings.patch
	eautoreconf
}

src_install() {
	emake DESTDIR=${D} install
	doman src/*.1
	dodoc ChangeLog
}
