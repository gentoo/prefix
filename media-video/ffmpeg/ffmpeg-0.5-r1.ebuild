# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-video/ffmpeg/ffmpeg-0.5-r1.ebuild,v 1.4 2009/04/04 15:05:05 armin76 Exp $

EAPI=1

inherit eutils flag-o-matic multilib toolchain-funcs

DESCRIPTION="Complete solution to record, convert and stream audio and video.
Includes libavcodec."
HOMEPAGE="http://ffmpeg.org/"
SRC_URI="http://ffmpeg.org/releases/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="+3dnow +3dnowext alsa altivec amr custom-cflags debug dirac doc ieee1394
	  +encode faac faad gsm ipv6 +mmx +mmxext vorbis test theora threads x264
	  xvid network zlib sdl X mp3 oss schroedinger +hardcoded-tables bindist
	  v4l v4l2 speex +ssse3 vhook jpeg2k"

RDEPEND="vhook? ( >=media-libs/imlib2-1.4.0 >=media-libs/freetype-2 )
	sdl? ( >=media-libs/libsdl-1.2.10 )
	alsa? ( media-libs/alsa-lib )
	encode? (
		faac? ( media-libs/faac )
		mp3? ( media-sound/lame )
		vorbis? ( media-libs/libvorbis media-libs/libogg )
		theora? ( media-libs/libtheora media-libs/libogg )
		x264? ( >=media-libs/x264-0.0.20081006 )
		xvid? ( >=media-libs/xvid-1.1.0 ) )
	faad? ( >=media-libs/faad2-2.6.1 )
	zlib? ( sys-libs/zlib )
	ieee1394? ( media-libs/libdc1394
				sys-libs/libraw1394 )
	dirac? ( media-video/dirac )
	gsm? ( >=media-sound/gsm-1.0.12-r1 )
	jpeg2k? ( >=media-libs/openjpeg-1.3-r2 )
	schroedinger? ( media-libs/schroedinger )
	speex? ( >=media-libs/speex-1.2_beta3 )
	X? ( x11-libs/libX11 x11-libs/libXext )
	amr? ( media-libs/amrnb media-libs/amrwb )"

DEPEND="${RDEPEND}
	>=sys-devel/make-3.81
	mmx? ( dev-lang/yasm )
	doc? ( app-text/texi2html )
	test? ( net-misc/wget )
	v4l? ( sys-kernel/linux-headers )
	v4l2? ( sys-kernel/linux-headers )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-0.4.9_p20090201-solaris.patch
	epatch "${FILESDIR}"/${PN}-0.4.9_p20090201-apple.patch
	# /bin/sh on at least Solaris can't cope very will with these scripts
	sed -i -e '1c\#!/usr/bin/env sh' configure version.sh || die
}

src_compile() {
	local myconf="${EXTRA_ECONF}"

	# enabled by default
	use debug || myconf="${myconf} --disable-debug"
	use zlib || myconf="${myconf} --disable-zlib"
	use sdl || myconf="${myconf} --disable-ffplay"

	if use network; then
		use ipv6 || myconf="${myconf} --disable-ipv6"
	else
		myconf="${myconf} --disable-network"
	fi

	use custom-cflags && myconf="${myconf} --disable-optimizations"

	# enabled by default
	if use encode
	then
		use faac && myconf="${myconf} --enable-libfaac"
		use mp3 && myconf="${myconf} --enable-libmp3lame"
		use vorbis && myconf="${myconf} --enable-libvorbis"
		use theora && myconf="${myconf} --enable-libtheora"
		use x264 && myconf="${myconf} --enable-libx264"
		use xvid && myconf="${myconf} --enable-libxvid"
	else
		myconf="${myconf} --disable-encoders"
	fi

	# libavdevice options
	use ieee1394 && myconf="${myconf} --enable-libdc1394"
	# Demuxers
	for i in v4l v4l2 alsa oss ; do
		use $i || myconf="${myconf} --disable-demuxer=$i"
	done
	# Muxers
	for i in alsa oss ; do
		use $i || myconf="${myconf} --disable-muxer=$i"
	done
	use X && myconf="${myconf} --enable-x11grab"

	# Threads; we only support pthread for now but ffmpeg supports more
	use threads && myconf="${myconf} --enable-pthreads"

	# Decoders
	use faad && myconf="${myconf} --enable-libfaad"
	use dirac && myconf="${myconf} --enable-libdirac"
	use schroedinger && myconf="${myconf} --enable-libschroedinger"
	use speex && myconf="${myconf} --enable-libspeex"
	use jpeg2k && myconf="${myconf} --enable-libopenjpeg"
	if use gsm; then
		myconf="${myconf} --enable-libgsm"
		# Crappy detection or our installation is weird, pick one (FIXME)
		append-flags -I"${EPREFIX}"/usr/include/gsm
	fi
	if use bindist
	then
		use amr && ewarn "libamr is nonfree and cannot be distributed; disabling amr support."
	else
		use amr && myconf="${myconf} --enable-libamr-nb \
									 --enable-libamr-wb \
									 --enable-nonfree"
	fi

	# CPU features
	for i in mmx ssse3 altivec ; do
		use $i ||  myconf="${myconf} --disable-$i"
	done
	use mmxext || myconf="${myconf} --disable-mmx2"
	use 3dnow || myconf="${myconf} --disable-amd3dnow"
	use 3dnowext || myconf="${myconf} --disable-amd3dnowext"
	# disable mmx accelerated code if PIC is required
	# as the provided asm decidedly is not PIC.
	if gcc-specs-pie ; then
		myconf="${myconf} --disable-mmx --disable-mmx2"
	fi

	# Try to get cpu type based on CFLAGS.
	# Bug #172723
	# We need to do this so that features of that CPU will be better used
	# If they contain an unknown CPU it will not hurt since ffmpeg's configure
	# will just ignore it.
	for i in $(get-flag march) $(get-flag mcpu) $(get-flag mtune) ; do
		myconf="${myconf} --cpu=$i"
		break
	done

	# video hooking support. replaced by libavfilter, probably needs to be
	# dropped at some point.
	use vhook || myconf="${myconf} --disable-vhook"

	# Mandatory configuration
	myconf="${myconf} --enable-gpl --enable-postproc \
			--enable-avfilter --enable-avfilter-lavf \
			--enable-swscale --disable-stripping"

	# cross compile support
	tc-is-cross-compiler && myconf="${myconf} --enable-cross-compile --arch=$(tc-arch-kernel)"

	# Misc stuff
	use hardcoded-tables && myconf="${myconf} --enable-hardcoded-tables"

	# Specific workarounds for too-few-registers arch...
	if [[ $(tc-arch) == "x86" || $(tc-arch) == x86-* ]]; then
		filter-flags -fforce-addr -momit-leaf-frame-pointer
		append-flags -fomit-frame-pointer
		is-flag -O? || append-flags -O2
		if (use debug); then
			# no need to warn about debug if not using debug flag
			ewarn ""
			ewarn "Debug information will be almost useless as the frame pointer is omitted."
			ewarn "This makes debugging harder, so crashes that has no fixed behavior are"
			ewarn "difficult to fix. Please have that in mind."
			ewarn ""
		fi
	fi

	local arch=${CHOST%%-*}
	# Gentoo Linux ppc64 has powerpc64-* CHOST, but configure doesn't get that
	[[ ${arch} == powerpc64 ]] && arch=ppc64

	cd "${S}"
	./configure \
		--prefix="${EPREFIX}"/usr \
		--libdir="${EPREFIX}"/usr/$(get_libdir) \
		--shlibdir="${EPREFIX}"/usr/$(get_libdir) \
		--mandir="${EPREFIX}"/usr/share/man \
		--enable-static --enable-shared \
		--arch=${CHOST%%-*} \
		--cc="$(tc-getCC)" \
		${myconf} || die "configure failed"

	emake version.h || die #252269
	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "Install Failed"

	dodoc Changelog README INSTALL
	dodoc doc/*
}

# Never die for now...
src_test() {
	for t in codectest libavtest seektest ; do
		emake ${t} || ewarn "Some tests in ${t} failed"
	done
}
