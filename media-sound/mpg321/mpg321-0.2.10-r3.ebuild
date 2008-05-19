# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mpg321/mpg321-0.2.10-r3.ebuild,v 1.11 2008/05/18 14:51:36 drac Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Free MP3 player, drop-in replacement for mpg123"
HOMEPAGE="http://sourceforge.net/projects/mpg321"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND="media-libs/libmad
	media-libs/libid3tag
	media-libs/libao"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# from debian?
	epatch "${FILESDIR}"/${P}-file-descriptors-leak.patch
	# provide an User-Agent when requesting via HTTP
	# By Frank Ruell, in FreeBSD PR 84898
	epatch "${FILESDIR}"/${P}-useragent.patch
}

src_compile() {
	# disabling the symlink here and doing it in postinst is better for GRP
	econf --disable-mpg123-symlink
	emake || die "emake failed."
}

src_install () {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS BUGS ChangeLog HACKING NEWS README README.remote THANKS TODO
}

pkg_postinst() {
	# We create a symlink for /usr/bin/mpg123 if it doesn't already exist
	if ! [ -f "${EROOT}"usr/bin/mpg123 ]; then
		ln -s mpg321 "${EROOT}"usr/bin/mpg123
	fi
}

pkg_postrm() {
	# We delete the symlink if it's nolonger valid.
	if [ -L "${EROOT}usr/bin/mpg123" ] && [ ! -x "${EROOT}usr/bin/mpg123" ]; then
		elog "We are removing the ${EROOT}usr/bin/mpg123 symlink since it is no longer valid."
		elog "If you are using another virtual/mpg123 program, you should setup the appropriate symlink."
		rm "${EROOT}"usr/bin/mpg123
	fi
}
