# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/media-video/mplayer/mplayer-1.0.20070427.ebuild,v 1.2 2007/05/20 22:46:57 beandog Exp $

EAPI="prefix"

inherit eutils flag-o-matic multilib

RESTRICT="nostrip"
IUSE="3dnow 3dnowext a52 aac aalib alsa altivec amr arts bidi bl bindist cddb
cpudetection custom-cflags debug dga doc dts dvb cdparanoia directfb dvd dvdnav
dv dvdread enca encode esd fbcon ftp gif ggi gtk iconv ipv6 ivtv jack joystick
jpeg libcaca lirc live livecd lzo mad md5sum mmx mmxext mp2 mp3 musepack nas
unicode vorbis opengl openal oss png pnm quicktime radio rar real rtc samba sdl
speex srt sse sse2 svga tga theora tivo truetype v4l v4l2 vidix win32codecs X
x264 xanim xinerama xv xvid xvmc zoran"

VIDEO_CARDS="s3virge mga tdfx vesa"

for X in ${VIDEO_CARDS}; do
	IUSE="${IUSE} video_cards_${X}"
done

BLUV=1.7
SVGV=1.9.17
MY_PV="20070427"
S="${WORKDIR}/${PN}-${MY_PV}"
AMR_URI="http://www.3gpp.org/ftp/Specs/archive"
SRC_URI="mirror://gentoo/${PN}-${MY_PV}.tar.bz2
	!truetype? ( mirror://mplayer/releases/fonts/font-arial-iso-8859-1.tar.bz2
				 mirror://mplayer/releases/fonts/font-arial-iso-8859-2.tar.bz2
				 mirror://mplayer/releases/fonts/font-arial-cp1250.tar.bz2 )
	!iconv? ( mirror://mplayer/releases/fonts/font-arial-iso-8859-1.tar.bz2
			  mirror://mplayer/releases/fonts/font-arial-iso-8859-2.tar.bz2
			  mirror://mplayer/releases/fonts/font-arial-cp1250.tar.bz2 )
	gtk? ( mirror://mplayer/Skin/Blue-${BLUV}.tar.bz2 )
	svga? ( http://mplayerhq.hu/~alex/svgalib_helper-${SVGV}-mplayer.tar.bz2 )
	amr? ( ${AMR_URI}/26_series/26.104/26104-510.zip
		   ${AMR_URI}/26_series/26.204/26204-510.zip )"

DESCRIPTION="Media Player for Linux "
HOMEPAGE="http://www.mplayerhq.hu/"

RDEPEND="sys-libs/ncurses
	!livecd? (
		!bindist? (
			x86? (
				win32codecs? ( media-libs/win32codecs )
				real? ( media-libs/win32codecs
					media-video/realplayer )
				)
			amd64? ( real? ( media-libs/amd64codecs ) )
		)
	)
	aalib? ( media-libs/aalib )
	alsa? ( media-libs/alsa-lib )
	arts? ( kde-base/arts )
	openal? ( media-libs/openal )
	bidi? ( dev-libs/fribidi )
	cdparanoia? ( media-sound/cdparanoia )
	directfb? ( dev-libs/DirectFB )
	dts? ( media-libs/libdts )
	dv? ( media-libs/libdv )
	dvb? ( media-tv/linuxtv-dvb-headers )
	dvd? ( dvdnav? ( media-libs/libdvdnav ) )
	encode? (
		aac? ( media-libs/faac )
		mp2? ( media-sound/twolame )
		mp3? ( media-sound/lame )
		)
	esd? ( media-sound/esound )
	enca? ( app-i18n/enca )
	gif? ( media-libs/giflib )
	ggi? ( media-libs/libggi )
	gtk? ( media-libs/libpng
		x11-libs/libXxf86vm
		x11-libs/libXext
		x11-libs/libXi
		=x11-libs/gtk+-2* )
	jpeg? ( media-libs/jpeg )
	libcaca? ( media-libs/libcaca )
	lirc? ( app-misc/lirc )
	lzo? ( >=dev-libs/lzo-2 )
	mad? ( media-libs/libmad )
	musepack? ( >=media-libs/libmpcdec-1.2.2 )
	nas? ( media-libs/nas )
	opengl? ( virtual/opengl )
	png? ( media-libs/libpng )
	pnm? ( media-libs/netpbm )
	samba? ( net-fs/samba )
	sdl? ( media-libs/libsdl )
	speex? ( >=media-libs/speex-1.1.7 )
	srt? ( >=media-libs/freetype-2.1
		media-libs/fontconfig )
	svga? ( media-libs/svgalib )
	theora? ( media-libs/libtheora )
	live? ( >=media-plugins/live-2007.02.20 )
	truetype? ( >=media-libs/freetype-2.1
		media-libs/fontconfig )
	vidix? ( x11-libs/libXxf86vm
			 x11-libs/libXext )
	x264? ( media-libs/x264-svn )
	xanim? ( media-video/xanim )
	xinerama? ( x11-libs/libXinerama
		x11-libs/libXxf86vm
		x11-libs/libXext )
	xv? ( x11-libs/libXv
		x11-libs/libXxf86vm
		x11-libs/libXext
		xvmc? ( x11-libs/libXvMC ) )
	xvid? ( media-libs/xvid )
	X? ( x11-libs/libXxf86vm
		x11-libs/libXext
		joystick? ( x11-drivers/xf86-input-joystick )
	)"
#	video_cards_vesa? ( sys-apps/vbetool ) restrict on x86 first

DEPEND="${RDEPEND}
	app-arch/unzip
	doc? ( >=app-text/docbook-sgml-dtd-4.1.2
		app-text/docbook-xml-dtd
		>=app-text/docbook-xml-simple-dtd-1.50.0
		dev-libs/libxslt
	)
	dga? ( x11-proto/xf86dgaproto )
	xinerama? ( x11-proto/xineramaproto )
	xv? ( x11-proto/videoproto
		  x11-proto/xf86vidmodeproto )
	gtk? ( x11-proto/xextproto
		   x11-proto/xf86vidmodeproto )
	X? ( x11-proto/xextproto
		 x11-proto/xf86vidmodeproto )
	iconv? ( virtual/libiconv )"
# Make sure the assembler USE flags are unmasked on amd64
# Remove this once default-linux/amd64/2006.1 is deprecated
DEPEND="${DEPEND} amd64? ( >=sys-apps/portage-2.1.2 )
	mp2? ( >=sys-apps/portage-2.1.2 )
	ivtv? ( !x86-fbsd? ( <sys-kernel/linux-headers-2.6.20
		media-tv/ivtv
		>=sys-apps/portage-2.1.2 ) )"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"

pkg_setup() {

	if [[ -n ${LINGUAS} ]]; then
		elog "For MPlayer's language support, the configuration will"
		elog "use your LINGUAS variable from /etc/make.conf.  If you have more"
		elog "than one language enabled, then the first one in the list will"
		elog "be used to output the messages, if a translation is available."
		elog "man pages will be created for all languages where translations"
		elog "are also available."
	fi

}

src_unpack() {

	unpack ${PN}-${MY_PV}.tar.bz2

	if ! use truetype ; then
		unpack font-arial-iso-8859-1.tar.bz2 \
			font-arial-iso-8859-2.tar.bz2 \
			font-arial-cp1250.tar.bz2
	fi

	use gtk && unpack Blue-${BLUV}.tar.bz2

	use svga && unpack svgalib_helper-${SVGV}-mplayer.tar.bz2

	use amr && unpack 26104-510.zip && unpack 26204-510.zip

	# amr (float) support
	if use amr; then
		einfo "Including amr wide and narrow band (float) support ... "

		# narrow band codec
		mkdir ${S}/libavcodec/amr_float
		cd ${S}/libavcodec/amr_float
		unzip -q ${WORKDIR}/26104-510_ANSI_C_source_code.zip
		# wide band codec
		mkdir ${S}/libavcodec/amrwb_float
		cd ${S}/libavcodec/amrwb_float
		unzip -q ${WORKDIR}/26204-510_ANSI-C_source_code.zip
	fi

	cd ${S}

	# Fix hppa compilation
	use hppa && sed -i -e "s/-O4/-O1/" "${S}/configure"

	if use svga; then
		echo
		einfo "Enabling vidix non-root mode."
		einfo "(You need a proper svgalib_helper.o module for your kernel"
		einfo " to actually use this)"
		echo

		mv ${WORKDIR}/svgalib_helper ${S}/libdha
	fi

	# Remove kernel-2.6 workaround as the problem it works around is
	# fixed, and the workaround breaks sparc
	# use sparc && sed -i 's:#define __KERNEL__::' osdep/kerneltwosix.h

	# minor fix
	# sed -i -e "s:-O4:-O4 -D__STDC_LIMIT_MACROS:" configure

	# Fix XShape detection
	epatch ${FILESDIR}/${PN}-xshape.patch

}

src_compile() {

	local myconf=" --disable-tv-bsdbt848 \
		--disable-faad-external \
		--disable-libcdio"

	# MPlayer reads in the LINGUAS variable from make.conf, and sets
	# the languages accordingly.  Some will have to be altered to match
	# upstream's naming scheme.
	[[ -n $LINGUAS ]] && LINGUAS=${LINGUAS/da/dk}

	################
	#Optional features#
	###############
	use bidi || myconf="${myconf} --disable-fribidi"
	use bl && myconf="${myconf} --enable-bl"
	use cddb || myconf="${myconf} --disable-cddb"
	use cdparanoia || myconf="${myconf} --disable-cdparanoia"
	use enca || myconf="${myconf} --disable-enca"
	use ftp || myconf="${myconf} --disable-ftp"
	use tivo || myconf="${myconf} --disable-vstream"


	# DVD support
	# dvdread and libdvdcss are internal libs
	# http://www.mplayerhq.hu/DOCS/HTML/en/dvd.html
	# You can optionally use external dvdread support, but against
	# upstream's suggestion.  We don't.
	# dvdnav support is known to be buggy, but it is the only option
	# for accessing some DVDs.
	if use dvd; then
		use dvdread || myconf="${myconf} --disable-dvdread"
		use dvdnav || myconf="${myconf} --disable-dvdnav"
	else
		myconf="${myconf} --disable-dvdnav --disable-dvdread"
	fi

	if use encode; then
		use aac || myconf="${myconf} --disable-faac"
		use dv || myconf="${myconf} --disable-libdv"
		use x264 || myconf="${myconf} --disable-x264"
	else
		myconf="${myconf} --disable-mencoder --disable-libdv --disable-x264 \
			--disable-faac"
	fi

	# SRT (subtitles) requires freetype support
	# freetype support requires iconv
	# iconv optionally can use unicode
	if ! use srt; then
		myconf="${myconf} --disable-ass"
		if ! use truetype; then
			myconf="${myconf} --disable-freetype"
			if ! use iconv; then
				myconf="${myconf} --disable-iconv --charset=noconv"
			fi
		fi
	fi
	use iconv && use unicode && myconf="${myconf} --charset=UTF-8"

	use lirc || myconf="${myconf} --disable-lirc --disable-lircc"
	myconf="${myconf} $(use_enable joystick)"
	use ipv6 || myconf="${myconf} --disable-inet6"
	use rar || myconf="${myconf} --disable-unrarlib"
	use rtc || myconf="${myconf} --disable-rtc"
	use samba || myconf="${myconf} --disable-smb"

	# DVB / Video4Linux / Radio support
	if ( use dvb || use v4l || use v4l2 || use radio ); then
		use dvb || myconf="${myconf} --disable-dvb --disable-dvbhead"
		use v4l	|| myconf="${myconf} --disable-tv-v4l1"
		use v4l2 || myconf="${myconf} --disable-tv-v4l2"
		if ( use dvb || use v4l || use v4l2 ) && use radio; then
			myconf="${myconf} --enable-radio $(use_enable encode radio-capture)"
		else
			myconf="${myconf} --disable-radio-v4l2 --disable-radio-bsdbt848"
		fi
	else
		myconf="${myconf} --disable-tv --disable-tv-v4l1 --disable-tv-v4l2 \
			--disable-radio --disable-radio-v4l2 --disable-radio-bsdbt848 \
			--disable-dvb --disable-dvbhead"
	fi

	# disable PVR support
	# The build will break if you have media-tv/ivtv installed and
	# linux-headers != 2.6.18, which is currently not keyworded
	# See also, bug 164748
	myconf="${myconf} --disable-pvr"

	#########
	# Codecs #
	########
	for x in gif jpeg live mad musepack pnm speex tga theora xanim xvid; do
		use ${x} || myconf="${myconf} --disable-${x}"
	done
	use aac || myconf="${myconf} --disable-faad-internal"
	use a52 || myconf="${myconf} --disable-liba52"
	use dts || myconf="${myconf} --disable-libdts"
	! use png && ! use gtk && myconf="${myconf} --disable-png"
	use lzo || myconf="${myconf} --disable-liblzo"
	use encode && use mp2 || myconf="${myconf} --disable-twolame \
		--disable-toolame"
	use mp3 || myconf="${myconf} --disable-mp3lib"
	use quicktime || myconf="${myconf} --disable-qtx"
	use vorbis || myconf="${myconf} --disable-libvorbis"
	use xanim && myconf="${myconf} --xanimcodecsdir=/usr/lib/xanim/mods"
	if use x86 || use amd64; then
		# Real codec support, only available on x86, amd64
		if use real && use x86; then
			myconf="${myconf} --realcodecsdir=/opt/RealPlayer/codecs"
		elif use real && use amd64; then
			myconf="${myconf} --realcodecsdir=/usr/$(get_libdir)/codecs"
		else
			myconf="${myconf} --disable-real"
		fi
		if ! use livecd && ! use bindist && ! use real; then
			myconf="${myconf} $(use_enable win32codecs win32dll)"
		fi
	fi

	#############
	# Video Output #
	#############

	for x in directfb ivtv ggi md5sum sdl xinerama; do
		use ${x} || myconf="${myconf} --disable-${x}"
	done
	use aalib || myconf="${myconf} --disable-aa"
	use fbcon || myconf="${myconf} --disable-fbdev"
	use fbcon && use video_cards_s3virge && myconf="${myconf} --enable-s3fb"
	use libcaca || myconf="${myconf} --disable-caca"
	use opengl || myconf="${myconf} --disable-gl"
	use video_cards_mga || myconf="${myconf} --disable-mga"
	( use X && use video_cards_mga ) || myconf="${myconf} --disable-xmga"
	use video_cards_vesa || myconf="${myconf} --disable-vesa"
	use vidix || myconf="${myconf} --disable-vidix-internal \
		--disable-vidix-external"
	use zoran || myconf="${myconf} --disable-zr"

	# GTK gmplayer gui
	myconf="${myconf} $(use_enable gtk gui)"

	if use xv; then
		if use xvmc; then
			myconf="${myconf} --enable-xvmc --with-xvmclib=XvMCW"
		else
			myconf="${myconf} --disable-xvmc"
		fi
	else
		myconf="${myconf} --disable-xv --disable-xvmc"
	fi

	if use video_cards_tdfx; then
		myconf="${myconf} $(use_enable video_cards_tdfx tdfxvid) \
			$(use_enable fbcon tdfxfb)"
	else
		myconf="${myconf} --disable-3dfx --disable-tdfxvid --disable-tdfxfb"
	fi

	#macos stuff
	if [[ ${CHOST} == "*-apple-darwin*" ]] ; then
		myconf="$myconf --enable-macosx	--enable-macosx-finder-support --enable-macosx-bundle"
	fi

	#############
	# Audio Output #
	#############
	for x in alsa arts esd jack nas openal; do
		use ${x} || myconf="${myconf} --disable-${x}"
	done
	if ! use radio; then
		use oss || myconf="${myconf} --disable-ossaudio"
	fi

	#################
	# Advanced Options #
	#################
	# Platform specific flags, hardcoded on amd64 (see below)
	if use x86 || use amd64 || use ppc; then
		if use cpudetection || use livecd || use bindist; then
			myconf="${myconf} --enable-runtime-cpudetection"
		fi
	fi
	if use mmx; then
		for x in 3dnow 3dnowext mmxext sse sse2; do
			use ${x} || myconf="${myconf} --disable-${x}"
		done
	else
		myconf="${myconf} --disable-mmx --disable-mmxext --disable-sse \
		--disable-sse2 --disable-3dnow --disable-3dnowext"
	fi
	use debug && myconf="${myconf} --enable-debug=3"

	if use ppc64 && use altivec; then
		myconf="${myconf} --enable-altivec"
		append-flags -maltivec -mabi=altivec
	else
		myconf="${myconf} --disable-altivec"
	fi

	if [ -e /dev/.devfsd ]; then
		myconf="${myconf} --enable-linux-devfs"
	fi

	#leave this in place till the configure/compilation borkage is completely corrected back to pre4-r4 levels.
	# it's intended for debugging so we can get the options we configure mplayer w/, rather then hunt about.
	# it *will* be removed asap; in the meantime, doesn't hurt anything.
	echo "${myconf}" > ${T}/configure-options

	if use custom-cflags; then
		# let's play the filtration game!  MPlayer hates on all!
		strip-flags
		# ugly optimizations cause MPlayer to cry on x86 systems!
			if use x86 ; then
				replace-flags -O* -O2
				filter-flags -fPIC -fPIE
				use debug || append-flags -fomit-frame-pointer
			fi
		append-flags -D__STDC_LIMIT_MACROS
	else
		unset CFLAGS CXXFLAGS
	fi

	myconf="--cc=$(tc-getCC) \
		--host-cc=$(tc-getBUILD_CC) \
		--prefix=${EPREFIX}/usr \
		--confdir=${EPREFIX}/etc/mplayer \
		--datadir=${EPREFIX}/usr/share/mplayer \
		--libdir=${EPREFIX}/usr/$(get_libdir) \
		--enable-largefiles \
		--enable-menu \
		--enable-network \
		--with-extraincdir="$(gcc-config -L)/include -I${EPREFIX}/usr/include" \
		${myconf}"
	einfo "Running ./configure"
	echo "CFLAGS=\"${CFLAGS}\" ./configure ${myconf}"
	CFLAGS="${CFLAGS}" ./configure ${myconf} || die

	# we run into problems if -jN > -j1
	# see #86245
	# This should have long ago been fixed, commenting out
	#MAKEOPTS="${MAKEOPTS} -j1"

	einfo "Make"
	emake || die "Failed to build MPlayer!"
	use doc && make -C DOCS/xml html-chunked
	einfo "Make completed"
}

src_install() {

	einfo "Make install"
	make prefix=${ED}/usr \
		 BINDIR=${ED}/usr/bin \
		 LIBDIR=${ED}/usr/$(get_libdir) \
		 CONFDIR=${ED}/etc/mplayer \
		 DATADIR=${ED}/usr/share/mplayer \
		 MANDIR=${ED}/usr/share/man \
		 install || die "Failed to install MPlayer!"
	einfo "Make install completed"

	dodoc AUTHORS Changelog README
	# Install the documentation; DOCS is all mixed up not just html
	if use doc ; then
		find "${S}/DOCS" -type d | xargs -- chmod 0755
		find "${S}/DOCS" -type f | xargs -- chmod 0644
		cp -r "${S}/DOCS" "${ED}/usr/share/doc/${PF}/" || die
	fi

	# Copy misc tools to documentation path, as they're not installed directly
	# and yes, we are nuking the +x bit.
	find "${S}/TOOLS" -type d | xargs -- chmod 0755
	find "${S}/TOOLS" -type f | xargs -- chmod 0644
	cp -r "${S}/TOOLS" "${ED}/usr/share/doc/${PF}/" || die

	# Install the default Skin and Gnome menu entry
	if use gtk; then
		dodir /usr/share/mplayer/skins
		cp -r ${WORKDIR}/Blue ${ED}/usr/share/mplayer/skins/default || die

		# Fix the symlink
		rm -rf ${ED}/usr/bin/gmplayer
		dosym mplayer /usr/bin/gmplayer

		insinto /usr/share/pixmaps
		newins ${ED}/Gui/mplayer/pixmaps/logo.xpm mplayer.xpm
		insinto /usr/share/applications
		doins ${FILESDIR}/mplayer.desktop
	fi

	if ! use srt && ! use truetype; then
		dodir /usr/share/mplayer/fonts
		local x=
		# Do this generic, as the mplayer people like to change the structure
		# of their zips ...
		for x in $(find ${WORKDIR}/ -type d -name 'font-arial-*')
		do
			cp -pPR ${x} ${ED}/usr/share/mplayer/fonts
		done
		# Fix the font symlink ...
		rm -rf ${ED}/usr/share/mplayer/font
		dosym fonts/font-arial-14-iso-8859-1 /usr/share/mplayer/font
	fi

	insinto /etc/mplayer
	newins ${S}/etc/example.conf mplayer.conf

	if use srt || use truetype;	then
		cat >> ${ED}/etc/mplayer/mplayer.conf << EOT
fontconfig=1
subfont-osd-scale=4
subfont-text-scale=3
EOT
	fi

	dosym ../../../etc/mplayer.conf /usr/share/mplayer/mplayer.conf

	#mv the midentify script to /usr/bin for emovix.
	#cp ${ED}/usr/share/doc/${PF}/TOOLS/midentify ${ED}/usr/bin
	#chmod a+x ${ED}/usr/bin/midentify
	dobin ${ED}/usr/share/doc/${PF}/TOOLS/midentify

	insinto /usr/share/mplayer
	doins ${S}/etc/input.conf
	doins ${S}/etc/menu.conf
}

pkg_preinst() {

	if [ -d "${EROOT}/usr/share/mplayer/Skin/default" ]
	then
		rm -rf ${EROOT}/usr/share/mplayer/Skin/default
	fi
}

pkg_postinst() {

	if use video_cards_mga; then
		depmod -a &>/dev/null || :
	fi

	if use dvdnav && use dvd; then
		ewarn "'dvdnav' support in MPlayer is known to be buggy, and will"
		ewarn "break if you are using it in GUI mode.  It is only"
		ewarn "included because some DVDs will only play with this feature."
		ewarn "If using it for playback only (and not menu navigation),"
		ewarn "specify the track # with your options."
		ewarn "mplayer dvdnav://1"
	fi
}

pkg_postrm() {

	# Cleanup stale symlinks
	if [ -L ${EROOT}/usr/share/mplayer/font -a \
		 ! -e ${EROOT}/usr/share/mplayer/font ]
	then
		rm -f ${EROOT}/usr/share/mplayer/font
	fi

	if [ -L ${EROOT}/usr/share/mplayer/subfont.ttf -a \
		 ! -e ${EROOT}/usr/share/mplayer/subfont.ttf ]
	then
		rm -f ${EROOT}/usr/share/mplayer/subfont.ttf
	fi
}
