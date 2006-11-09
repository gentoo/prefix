# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/jack-audio-connection-kit/jack-audio-connection-kit-0.100.7.ebuild,v 1.4 2006/03/05 22:56:18 kito Exp $

EAPI="prefix"

inherit flag-o-matic eutils multilib

DESCRIPTION="A low-latency audio server"
HOMEPAGE="http://www.jackaudio.org"
SRC_URI="mirror://sourceforge/jackit/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~ppc-macos"
IUSE="altivec alsa caps coreaudio doc debug jack-tmpfs mmx oss portaudio sndfile sse"

RDEPEND="sndfile? ( >=media-libs/libsndfile-1.0.0 )
	sys-libs/ncurses
	caps? ( sys-libs/libcap )
	portaudio? ( =media-libs/portaudio-18* )
	alsa? ( >=media-libs/alsa-lib-0.9.1 )
	!media-sound/jack-cvs"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? ( app-doc/doxygen )"

pkg_setup() {
	if ! use sndfile ; then
		ewarn "sndfile not in USE flags. jack_rec will not be installed!"
	fi

	if use caps; then
		if [[ "${KV:0:3}" == "2.4" ]]; then
			einfo "will build jackstart for 2.4 kernel"
		else
			einfo "using compatibility symlink for jackstart"
		fi
	fi

}

src_unpack() {
	unpack ${A}
	cd ${S}

	# the docs option is in upstream, I'll leave the pentium2 foobage
	# for the x86 folks...... kito@gentoo.org

	# Add doc option and fix --march=pentium2 in caps test
	#epatch ${FILESDIR}/${PN}-doc-option.patch

	# compile and install jackstart, see #92895, #94887
	#if use caps ; then
	#	epatch ${FILESDIR}/${PN}-0.99.0-jackstart.patch
	#fi

	epatch ${FILESDIR}/${PN}-transport.patch
}

src_compile() {
	local myconf

	sed -i "s/^CFLAGS=\$JACK_CFLAGS/CFLAGS=\"\$JACK_CFLAGS $(get-flag -march)\"/" configure

	use doc && myconf="--with-html-dir=${EPREFIX}/usr/share/doc/${PF}"

	if use jack-tmpfs; then
		myconf="${myconf} --with-default-tmpdir=/dev/shm"
	else
		myconf="${myconf} --with-default-tmpdir=${EPREFIX}/var/run/jack"
	fi

	if use userland_Darwin ; then
		append-flags -fno-common
		use altivec && append-flags -force_cpusubtype_ALL \
			-maltivec -mabi=altivec -mhard-float -mpowerpc-gfxopt
	fi

	use sndfile && \
		export SNDFILE_CFLAGS="-I${EPREFIX}/usr/include" \
		export SNDFILE_LIBS="-L${EPREFIX}/usr/$(get_libdir) -lsndfile"

	econf \
		$(use_enable altivec) \
		$(use_enable alsa) \
		$(use_enable caps capabilities) $(use_enable caps stripped-jackd) \
		$(use_enable coreaudio) \
		$(use_enable debug) \
		$(use_enable doc html-docs) \
		$(use_enable mmx) \
		$(use_enable oss) \
		$(use_enable portaudio) \
		$(use_enable sse) $(use_enable sse dynsimd) \
		--with-pic \
		${myconf} || die "configure failed"
	emake || die "compilation failed"

	if use caps && [[ "${KV:0:3}" == "2.4" ]]; then
		einfo "Building jackstart for 2.4 kernel"
		cd ${S}/jackd
		emake jackstart || die "jackstart build failed."
	fi

}

src_install() {
	make DESTDIR=${D} datadir=${EPREFIX}/usr/share/doc install || die

	if use caps; then
		if [[ "${KV:0:3}" == "2.4" ]]; then
			cd ${S}/jackd
			dobin jackstart
		else
			dosym /usr/bin/jackd /usr/bin/jackstart
		fi
	fi

	if ! use jack-tmpfs; then
		keepdir /var/run/jack
		chmod 4777 ${ED}/var/run/jack
	fi

	if use doc; then
		mv ${ED}/usr/share/doc/${PF}/reference/html \
		   ${ED}/usr/share/doc/${PF}/

		insinto /usr/share/doc/${PF}
		doins -r ${S}/example-clients
	else
		rm -rf ${ED}/usr/share/doc
	fi

	rm -rf ${ED}/usr/share/doc/${PF}/reference
}
