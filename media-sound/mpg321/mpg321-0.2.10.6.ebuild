# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mpg321/mpg321-0.2.10.6.ebuild,v 1.2 2009/06/22 04:32:14 ssuominen Exp $

EAPI=2
inherit autotools

DESCRIPTION="a realtime MPEG 1.0/2.0/2.5 audio player for layers 1, 2 and 3"
HOMEPAGE="http://packages.debian.org/mpg321"
SRC_URI="mirror://debian/pool/main/${PN:0:1}/${PN}/${PN}_${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="+alsa symlink"

RDEPEND="sys-libs/zlib
	media-libs/libmad
	media-libs/libid3tag
	media-libs/libao[alsa?]
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
	AT_M4DIR=m4 eautoreconf
}

src_configure() {
	local myao=oss
	use alsa && myao=alsa09

	econf \
		--disable-dependency-tracking \
		$(use_enable symlink mpg123-symlink) \
		--with-default-audio=${myao}
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	newdoc debian/changelog ChangeLog.debian
	dodoc AUTHORS BUGS HACKING NEWS README{,.remote} THANKS TODO
}

pkg_postinst() {
	if ! use symlink; then
		ewarn "USE symlink is disabled by default on purpose, to get people"
		ewarn "to switch back into using mpg123 since it's been freed."
		ewarn "See ChangeLog.debian in /usr/share/doc/${PF} for details."
	fi
}
