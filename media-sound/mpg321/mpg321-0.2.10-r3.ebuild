# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/mpg321/mpg321-0.2.10-r3.ebuild,v 1.3 2006/10/04 17:10:46 grobian Exp $

EAPI="prefix"

inherit eutils

IUSE=""

DESCRIPTION="Free MP3 player, drop-in replacement for mpg123"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
HOMEPAGE="http://sourceforge.net/projects/mpg321/"

DEPEND="media-libs/libmad
	media-libs/libid3tag
	>=media-libs/libao-0.8.0"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"

PROVIDE="virtual/mpg123"

src_unpack() {
	unpack ${A}
	cd ${S}

	# fix file descriptors leak (from Debian?)
	epatch ${FILESDIR}/${P}.diff
	# provide an User-Agent when requesting via HTTP
	# By Frank Ruell, in FreeBSD PR 84898
	epatch ${FILESDIR}/${P}-useragent.patch
}

src_compile() {
	# disabling the symlink here and doing it in postinst is better for GRP
	econf --disable-mpg123-symlink || die
	emake || die
}

src_install () {
	make DESTDIR="${D}" install || die
	dodoc AUTHORS BUGS ChangeLog HACKING NEWS README README.remote THANKS TODO
}

pkg_postinst() {
	# We create a symlink for /usr/bin/mpg123 if it doesn't already exist
	if ! [ -f ${EROOT}/usr/bin/mpg123 ]; then
		ln -s mpg321 ${EROOT}/usr/bin/mpg123
	fi
}

pkg_postrm() {
	# We delete the symlink if it's nolonger valid.
	if [ -L "${EROOT}/usr/bin/mpg123" ] && [ ! -x "${EROOT}/usr/bin/mpg123" ]; then
		einfo "We are removing the ${EROOT}/usr/bin/mpg123 symlink since it is no longer valid."
		einfo "If you are using another virtual/mpg123 program, you should setup the appropriate symlink."
		rm ${EROOT}/usr/bin/mpg123
	fi
}
