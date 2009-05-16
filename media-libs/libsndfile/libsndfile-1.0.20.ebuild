# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/libsndfile/libsndfile-1.0.20.ebuild,v 1.4 2009/05/15 22:01:40 maekke Exp $

inherit eutils libtool autotools

MY_P=${P/_pre/pre}

DESCRIPTION="A C library for reading and writing files containing sampled sound"
HOMEPAGE="http://www.mega-nerd.com/libsndfile"
if [[ "${MY_P}" == "${P}" ]]; then
	SRC_URI="http://www.mega-nerd.com/libsndfile/${P}.tar.gz"
else
	SRC_URI="http://www.mega-nerd.com/tmp/${MY_P}b.tar.gz"
fi

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="alsa jack minimal sqlite"

RDEPEND="!minimal? ( >=media-libs/flac-1.2.1
		>=media-libs/libogg-1.1.3
		>=media-libs/libvorbis-1.2.1_rc1 )
	alsa? ( media-libs/alsa-lib )
	sqlite? ( >=dev-db/sqlite-3.2 )
	jack? ( media-sound/jack-audio-connection-kit )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e "s/noinst_PROGRAMS/check_PROGRAMS/" "${S}/tests/Makefile.am" \
		"${S}/examples/Makefile.am" || die "sed failed"

	epatch "${FILESDIR}"/${PN}-1.0.17-regtests-need-sqlite.patch \
		"${FILESDIR}"/${PN}-1.0.18-less_strict_tests.patch \
		"${FILESDIR}"/${PN}-1.0.19-automagic_jack.patch

	rm M4/libtool.m4 M4/lt*.m4 || die "rm failed"

	AT_M4DIR=M4 eautoreconf
	epunt_cxx
}

src_compile() {
	econf $(use_enable sqlite) \
		$(use_enable alsa) \
		$(use_enable jack) \
		$(use_enable !minimal external-libs) \
		--disable-octave \
		--disable-gcc-werror \
		--disable-gcc-pipe \
		--disable-dependency-tracking
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" htmldocdir="${EPREFIX}/usr/share/doc/${PF}/html" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO
}
