# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/jack-audio-connection-kit/jack-audio-connection-kit-0.102.20.ebuild,v 1.3 2007/02/28 22:16:44 genstef Exp $

EAPI="prefix"

inherit flag-o-matic eutils multilib

NETJACK=netjack-0.12rc1

DESCRIPTION="A low-latency audio server"
HOMEPAGE="http://www.jackaudio.org"
SRC_URI="mirror://sourceforge/jackit/${P}.tar.gz http://netjack.sourceforge.net/${NETJACK}.tar.bz2"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~ppc-macos"
IUSE="altivec alsa caps coreaudio doc debug jack-tmpfs mmx oss portaudio sndfile sse netjack cpudetection"

RDEPEND="sndfile? ( >=media-libs/libsndfile-1.0.0 )
	sys-libs/ncurses
	caps? ( sys-libs/libcap )
	portaudio? ( =media-libs/portaudio-18* )
	alsa? ( >=media-libs/alsa-lib-0.9.1 )
	!media-sound/jack-cvs"

DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )
	netjack? ( dev-util/scons )"

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

	if use netjack; then
		einfo "including support for experimental netjack, see http://netjack.sourceforge.net/"
	fi
}

src_unpack() {
	unpack ${A}
	use netjack && unpack ${NETJACK}.tar.bz2
	cd ${S}

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

	# CPU Detection (dynsimd) uses asm routines which requires 3dnow, mmx and sse.
	# Also, without -O2 it will not compile as well.
	# we test if it is present before enabling the configure flag.
	if use cpudetection ; then
		if (! grep 3dnow /proc/cpuinfo >/dev/null) ; then
			ewarn "Can't build cpudetection (dynsimd) without cpu 3dnow support. see bug #136565."
		elif (! grep sse /proc/cpuinfo >/dev/null) ; then
			ewarn "Can't build cpudetection (dynsimd) without cpu sse support. see bug #136565."
		elif (! grep mmx /proc/cpuinfo >/dev/null) ; then
			ewarn "Can't build cpudetection (dynsimd) without cpu mmx support. see bug #136565."
		else
			einfo "Enabling cpudetection (dynsimd). Adding -mmmx, -msse, -m3dnow and -O2 to CFLAGS."
			myconf="${myconf} --enable-dynsimd"

			filter-flags -O*
			append-flags -mmmx -msse -m3dnow -O2
		fi
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
		$(use_enable sse) \
		--with-pic \
		${myconf} || die "configure failed"
	emake || die "compilation failed"

	if use caps && [[ "${KV:0:3}" == "2.4" ]]; then
		einfo "Building jackstart for 2.4 kernel"
		cd ${S}/jackd
		emake jackstart || die "jackstart build failed."
	fi

	if use netjack; then
		cd ${WORKDIR}/${NETJACK}
		scons jack_source_dir=${S}
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

	if use netjack; then
		cd ${WORKDIR}/${NETJACK}
		dobin alsa_in
		dobin alsa_out
		dobin jacknet_client
		insinto /usr/lib/jack
		doins jack_net.so
	fi
}
