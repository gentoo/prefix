# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/ecasound/ecasound-2.6.0.ebuild,v 1.7 2010/06/23 14:19:23 arfrever Exp $

EAPI=3

inherit eutils python autotools

DESCRIPTION="a package for multitrack audio processing"
HOMEPAGE="http://ecasound.seul.org/ecasound"
SRC_URI="http://${PN}.seul.org/download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="alsa audiofile debug doc jack libsamplerate mikmod ncurses vorbis oss python ruby sndfile"

RDEPEND="python? ( dev-lang/python )
	jack? ( media-sound/jack-audio-connection-kit )
	media-libs/ladspa-sdk
	audiofile? ( media-libs/audiofile )
	alsa? ( media-libs/alsa-lib )
	vorbis? ( media-libs/libvorbis )
	libsamplerate? ( media-libs/libsamplerate )
	mikmod? ( media-libs/libmikmod )
	ruby? ( dev-lang/ruby )
	python? ( dev-lang/python )
	ncurses? ( sys-libs/ncurses )
	sndfile? ( media-libs/libsndfile )
	sys-libs/readline"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-2.4.5-prefix.patch
	eautoreconf
}

src_configure() {
	local PYConf

	if use python; then
		PYConf="--enable-pyecasound=c
			--with-python-includes=${EPREFIX}$(python_get_includedir)
			--with-python-modules=${EPREFIX}$(python_get_libdir)"
	else
		PYConf="$myconf --disable-pyecasound"
	fi

	econf \
		$(use_enable alsa) \
		--disable-arts \
		$(use_enable audiofile) \
		$(use_enable debug) \
		$(use_enable jack) \
		$(use_enable libsamplerate) \
		$(use_enable ncurses) \
		$(use_enable oss) \
		$(use_enable ruby rubyecasound) \
		$(use_enable sndfile) \
		--enable-shared \
		--with-largefile \
		--enable-sys-readline \
		${PYConf} || die "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc BUGS NEWS README TODO Documentation/*.txt
	use doc && dohtml Documentation/*.html
}

pkg_postinst() {
	if use python; then
		python_mod_optimize ecacontrol.py eci.py pyeca.py
	fi
}

pkg_postrm() {
	if use python; then
		python_mod_cleanup ecacontrol.py eci.py pyeca.py
	fi
}
