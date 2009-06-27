# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mpg321/mpg321-0.2.10-r4.ebuild,v 1.2 2009/06/22 04:45:13 jer Exp $

EAPI=2
inherit eutils

DESCRIPTION="a realtime MPEG 1.0/2.0/2.5 audio player for layers 1, 2 and 3"
HOMEPAGE="http://packages.debian.org/mpg321"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="+symlink"

RDEPEND="sys-libs/zlib
	media-libs/libmad
	media-libs/libid3tag
	media-libs/libao
	!<media-sound/mpg321-0.2.10-r4
	symlink? ( !media-sound/mpg123 )"
DEPEND="${RDEPEND}"
PDEPEND="symlink? ( virtual/mpg123 )"

pkg_setup() {
	local link="${EROOT}usr/bin/mpg123"
	local msg="Removing invalid symlink ${link}"
	if use symlink; then
		if [ -L "${link}" ]; then
			ebegin "${msg}"
			rm -f "${link}" || die "${msg} failed, please open a bug."
			eend $?
		fi
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${P}-file-descriptors-leak.patch \
		"${FILESDIR}"/${P}-useragent.patch
}

src_configure() {
	econf \
		$(use_enable symlink mpg123-symlink)
}

src_install () {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS BUGS HACKING NEWS README{,.remote} THANKS TODO
}
