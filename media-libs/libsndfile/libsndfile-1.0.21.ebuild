# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libsndfile/libsndfile-1.0.21.ebuild,v 1.8 2010/06/12 12:08:21 ssuominen Exp $

inherit eutils libtool autotools flag-o-matic

MY_P=${P/_pre/pre}

DESCRIPTION="A C library for reading and writing files containing sampled sound"
HOMEPAGE="http://www.mega-nerd.com/libsndfile"
if [[ "${MY_P}" == "${P}" ]]; then
	SRC_URI="http://www.mega-nerd.com/libsndfile/files/${P}.tar.gz"
else
	SRC_URI="http://www.mega-nerd.com/tmp/${MY_P}b.tar.gz"
fi

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="alsa minimal sqlite"

RDEPEND="!minimal? ( >=media-libs/flac-1.2.1
		>=media-libs/libogg-1.1.3
		>=media-libs/libvorbis-1.2.1_rc1 )
	alsa? ( media-libs/alsa-lib )
	sqlite? ( >=dev-db/sqlite-3.2 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e "s/noinst_PROGRAMS/check_PROGRAMS/" "${S}/tests/Makefile.am" \
		"${S}/examples/Makefile.am" || die "sed failed"

	epatch "${FILESDIR}"/${PN}-1.0.17-regtests-need-sqlite.patch

	rm M4/libtool.m4 M4/lt*.m4 || die "rm failed"

	AT_M4DIR=M4 eautoreconf
	epunt_cxx
}

src_compile() {
	append-lfs-flags

	econf $(use_enable sqlite) \
		$(use_enable alsa) \
		$(use_enable !minimal external-libs) \
		--disable-octave \
		--disable-gcc-werror \
		--disable-gcc-pipe \
		--disable-dependency-tracking
	emake || die "emake failed, if you are on OpenSolaris, see bug #270233"
}

src_install() {
	emake DESTDIR="${D}" htmldocdir="${EPREFIX}/usr/share/doc/${PF}/html" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README
}
