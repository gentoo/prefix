# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/media-video/mplayer/mplayer-1.0_rc1-r2.ebuild,v 1.12 2007/02/17 14:16:40 blubb Exp $

EAPI="prefix"

inherit eutils flag-o-matic multilib

RESTRICT="nostrip"
IUSE="3dfx 3dnow 3dnowext aac aalib alsa altivec amr arts bidi bl bindist
cpudetection custom-cflags debug dga doc dts dvb cdparanoia directfb dvd
dv dvdread enca encode esd fbcon gif ggi gtk iconv ipv6 jack joystick jpeg
libcaca lirc live livecd lzo mad matrox mmx mmxext musepack nas unicode
vorbis opengl openal oss png real rtc samba sdl speex sse sse2 svga tga
theora truetype v4l v4l2 win32codecs X x264 xanim xinerama xv xvid xvmc"

LANGS="bg cs de da el en es fr hu ja ko mk nl no pl pt_BR ro ru sk tr uk zh_CN
zh_TW"

for X in ${LANGS} ; do
	IUSE="${IUSE} linguas_${X}"
done

BLUV=1.7
SVGV=1.9.17

# Handle PREversions as wel
MY_P="MPlayer-${PV/_/}"
S="${WORKDIR}/${MY_P}"
AMR_URI="http://www.3gpp.org/ftp/Specs/archive"
SRC_URI="mirror://mplayer/releases/${MY_P}.tar.bz2
	!truetype? ( mirror://mplayer/releases/fonts/font-arial-iso-8859-1.tar.bz2
				 mirror://mplayer/releases/fonts/font-arial-iso-8859-2.tar.bz2
				 mirror://mplayer/releases/fonts/font-arial-cp1250.tar.bz2 )
	!iconv? ( mirror://mplayer/releases/fonts/font-arial-iso-8859-1.tar.bz2
			  mirror://mplayer/releases/fonts/font-arial-iso-8859-2.tar.bz2
			  mirror://mplayer/releases/fonts/font-arial-cp1250.tar.bz2 )
	svga? ( http://mplayerhq.hu/~alex/svgalib_helper-${SVGV}-mplayer.tar.bz2 )
	gtk? ( mirror://mplayer/Skin/Blue-${BLUV}.tar.bz2 )
	amr? ( ${AMR_URI}/26_series/26.104/26104-510.zip
		   ${AMR_URI}/26_series/26.204/26204-510.zip )"

# Only install Skin if GUI should be build (gtk as USE flag)
DESCRIPTION="Media Player for Linux "
HOMEPAGE="http://www.mplayerhq.hu/"

# 'encode' in USE for MEncoder.
RDEPEND="xvid? ( >=media-libs/xvid-0.9.0 )
	win32codecs? (
		!livecd? (
			!bindist? ( >=media-libs/win32codecs-20040916 ) ) )
	x86? ( real? ( >=media-video/realplayer-10.0.3 ) )
	amd64? ( real? ( !bindist? ( media-libs/amd64codecs ) ) )
	aalib? ( media-libs/aalib )
	alsa? ( media-libs/alsa-lib )
	arts? ( kde-base/arts )
	openal? ( media-libs/openal )
	bidi? ( dev-libs/fribidi )
	cdparanoia? ( media-sound/cdparanoia )
	dga? ( x11-libs/libXxf86dga )
	directfb? ( dev-libs/DirectFB )
	dts? ( media-libs/libdts )
	dvb? ( media-tv/linuxtv-dvb-headers )
	dvd? ( dvdread? ( media-libs/libdvdread ) )
	encode? (
		media-sound/lame
		dv? ( >=media-libs/libdv-0.9.5 )
		x264? ( >=media-libs/x264-svn-20061014 )
		aac? ( media-libs/faac )
		)
	esd? ( media-sound/esound )
	enca? ( app-i18n/enca )
	gif? ( media-libs/giflib )
	ggi? ( media-libs/libggi )
	gtk? ( media-libs/libpng
		   x11-libs/libXxf86vm
		   x11-libs/libXext
		   x11-libs/libXi
		   =x11-libs/gtk+-2*
		   =dev-libs/glib-2* )
	jpeg? ( media-libs/jpeg )
	libcaca? ( media-libs/libcaca )
	lirc? ( app-misc/lirc )
	lzo? ( =dev-libs/lzo-1* )
	mad? ( media-libs/libmad )
	musepack? ( >=media-libs/libmpcdec-1.2.2 )
	nas? ( media-libs/nas )
	opengl? ( virtual/opengl )
	png? ( media-libs/libpng )
	samba? ( >=net-fs/samba-2.2.8a )
	sdl? ( media-libs/libsdl )
	speex? ( media-libs/speex )
	svga? ( media-libs/svgalib )
	theora? ( media-libs/libtheora )
	live? ( >=media-plugins/live-2004.07.20 )
	truetype? ( >=media-libs/freetype-2.1
				media-libs/fontconfig )
	xinerama? ( x11-libs/libXinerama
				x11-libs/libXxf86vm
				x11-libs/libXext )
	xanim? ( >=media-video/xanim-2.80.1-r4 )
	sys-libs/ncurses
	xv? ( x11-libs/libXv
		  x11-libs/libXxf86vm
		  x11-libs/libXext
		  xvmc? ( x11-libs/libXvMC ) )
	X? ( x11-libs/libXxf86vm
		 x11-libs/libXext )
	"

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
DEPEND="${DEPEND} amd64? ( >=sys-apps/portage-2.1.2 )"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"

pkg_setup() {
	if use real && use x86; then
		REALLIBDIR="/opt/RealPlayer/codecs"
	elif use real && use amd64 && ! use bindist ; then
		REALLIBDIR="/usr/$(get_libdir)/codecs"
	fi

	if use truetype && ! use iconv ; then
		ewarn "You enabled the 'truetype' USE flag, but support will be"
		ewarn "disabled unless you also use 'iconv'."
	fi
}

src_unpack() {

	unpack ${MY_P}.tar.bz2

	if ! use truetype || ! use iconv ; then
		unpack font-arial-iso-8859-1.tar.bz2 \
			   font-arial-iso-8859-2.tar.bz2 \
			   font-arial-cp1250.tar.bz2
	fi

	use svga && unpack svgalib_helper-${SVGV}-mplayer.tar.bz2

	use gtk && unpack Blue-${BLUV}.tar.bz2

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

	epatch "${FILESDIR}/mplayer-undefined-reference-fix.patch"

	# DSA 1244-1
	epatch "${FILESDIR}/${P}-asmrules.patch"

	# Fix hppa compilation
	[ "${ARCH}" = "hppa" ] && sed -i -e "s/-O4/-O1/" "${S}/configure"

	if use svga
	then
		echo
		einfo "Enabling vidix non-root mode."
		einfo "(You need a proper svgalib_helper.o module for your kernel"
		einfo " to actually use this)"
		echo

		mv ${WORKDIR}/svgalib_helper ${S}/libdha
	fi

	# Remove kernel-2.6 workaround as the problem it works around is
	# fixed, and the workaround breaks sparc
	use sparc && sed -i 's:#define __KERNEL__::' osdep/kerneltwosix.h

	# minor fix
	sed -i -e "s:-O4:-O4 -D__STDC_LIMIT_MACROS:" configure

}

src_compile() {

	# have fun with LINGUAS variable
	[[ -n $LINGUAS ]] && LINGUAS=${LINGUAS//da/dk}

	local myconf=" --disable-tv-bsdbt848 --disable-dvdnav"
	myconf="${myconf} --disable-vidix-external"
	################
	#Optional features#
	###############
	if use cpudetection || use livecd || use bindist
	then
	myconf="${myconf} --enable-runtime-cpudetection"
	fi

	myconf="${myconf} $(use_enable bidi fribidi)"

	if use iconv
	then
		use unicode && myconf="${myconf} --charset=UTF-8"
	else
		myconf="${myconf} --disable-iconv"
		myconf="${myconf} --charset=noconv"
	fi

	use enca || myconf="${myconf} --disable-enca"

	use cdparanoia || myconf="${myconf} --disable-cdparanoia"

	if use dvd
	then
		use dvdread && myconf="${myconf} --disable-mpdvdkit"
		use dvdread || myconf="${myconf} --disable-dvdread"
	else
		myconf="${myconf} --disable-dvdread --disable-mpdvdkit"
	fi

	if use encode
	then
		myconf="${myconf} --enable-mencoder"
		use dv || myconf="${myconf} --disable-libdv"
		use x264 || myconf="${myconf} --disable-x264"
		use aac || myconf="${myconf} --disable-faac"
	else
		myconf="${myconf} --disable-mencoder --disable-libdv --disable-x264
		--disable-faac"
	fi

	myconf="${myconf} $(use_enable gtk gui)"

	if use !gtk && use !X && use !xv && use !xinerama
	then
		myconf="${myconf} --disable-gui --disable-x11 --disable-xv --disable-xmga --disable-xinerama --disable-vm --disable-xvmc"
	else
		#note we ain't touching --enable-vm.  That should be locked down in the future.
		myconf="${myconf} --enable-x11 $(use_enable xinerama) $(use_enable xv) $(use_enable gtk gui)"
	fi

	if [[ ${CHOST} == "*-apple-darwin*" ]] ; then
		myconf="$myconf --enable-macosx --enable-macosx-finder-support --enable-macosx-bundle"
	fi

	# this looks like a hack, but the
	# --enable-dga needs a paramter, but there's no surefire
	# way to tell what it is.. so I'm letting MPlayer decide
	# the enable part
	if ! use dga && ! use 3dfx
	then
		myconf="${myconf} --disable-dga"
	fi
	# disable png *only* if gtk && png aren't on
	if use png || use gtk
	then
		myconf="${myconf} --enable-png"
	else
		myconf="${myconf} --disable-png"
	fi

	# disable PVR support
	# The build will break if you have media-tv/ivtv installed and
	# linux-headers != 2.6.18, which is currently not keyworded
	# See also, bug 164748
	myconf="${myconf} --disable-pvr --disable-ivtv"

	myconf="${myconf} $(use_enable ipv6 inet6)"
	myconf="${myconf} $(use_enable joystick)"
	myconf="${myconf} $(use_enable lirc)"
	myconf="${myconf} $(use_enable rtc)"
	myconf="${myconf} $(use_enable samba smb)"
	myconf="${myconf} $(use_enable truetype freetype)"
	use live || myconf="${myconf} --disable-live"
	use v4l	 || myconf="${myconf} --disable-tv-v4l1"
	use v4l2 || myconf="${myconf} --disable-tv-v4l2"
	use jack || myconf="${myconf} --disable-jack"

	#########
	# Codecs #
	########
	myconf="${myconf} $(use_enable gif)"
	myconf="${myconf} $(use_enable jpeg)"
	#myconf="${myconf} $(use_enable ladspa)"
	myconf="${myconf} $(use_enable dts libdts)"
	myconf="${myconf} $(use_enable lzo liblzo)"
	myconf="${myconf} $(use_enable musepack)"
	myconf="${myconf} $(use_enable aac faad-internal)"
	use vorbis || myconf="${myconf} --disable-libvorbis"
	myconf="${myconf} $(use_enable theora)"
	use speex || myconf="${myconf} --disable-speex"
	myconf="${myconf} $(use_enable xvid)"
	use x86 && myconf="${myconf} $(use_enable real)"
	! use livecd && ! use bindist && \
		myconf="${myconf} $(use_enable win32codecs win32)"

	#############
	# Video Output #
	#############
	myconf="${myconf} $(use_enable 3dfx)"
	if use 3dfx
	then
		myconf="${myconf} --enable-tdfxvid"
	else
		myconf="${myconf} --disable-tdfxvid"
	fi
	if use fbcon && use 3dfx
	then
		myconf="${myconf} --enable-tdfxfb"
	else
		myconf="${myconf} --disable-tdfxfb"
	fi

	if use dvb
	then
		myconf="${myconf} --enable-dvbhead"
	else
		myconf="${myconf} --disable-dvbhead"
	fi

	use aalib || myconf="${myconf} --disable-aa"
	myconf="${myconf} $(use_enable directfb)"
	myconf="${myconf} $(use_enable fbcon fbdev)"
	myconf="${myconf} $(use_enable ggi)"
	myconf="${myconf} $(use_enable libcaca caca)"
	if use matrox && use X
	then
		myconf="${myconf} $(use_enable matrox xmga)"
	fi
	myconf="${myconf} $(use_enable matrox mga)"
	myconf="${myconf} $(use_enable opengl gl)"
	myconf="${myconf} $(use_enable sdl)"

	if use svga
	then
		myconf="${myconf} --enable-svga"
	else
		myconf="${myconf} --disable-svga --disable-vidix-internal"
	fi

	myconf="${myconf} $(use_enable tga)"

	if use xv && use xvmc
	then
		myconf="${myconf} --enable-xvmc --with-xvmclib=XvMCW"
	else
		myconf="${myconf} --disable-xvmc"
	fi

	#############
	# Audio Output #
	#############
	use alsa || myconf="${myconf} --disable-alsa"
	use arts || myconf="${myconf} --disable-arts"
	use esd || myconf="${myconf} --disable-esd"
	use mad || myconf="${myconf} --disable-mad"
	use nas || myconf="${myconf} --disable-nas"
	use openal || myconf="${myconf} --disable-openal"
	use oss || myconf="${myconf} --disable-ossaudio"

	#################
	# Advanced Options #
	#################
	# Platform specific flags, hardcoded on amd64 (see below)
	myconf="${myconf} $(use_enable 3dnow)"
	myconf="${myconf} $(use_enable 3dnowext)";
	myconf="${myconf} $(use_enable sse)"
	myconf="${myconf} $(use_enable sse2)"
	myconf="${myconf} $(use_enable mmx)"
	myconf="${myconf} $(use_enable mmxext)"
	use debug && myconf="${myconf} --enable-debug=3"

	if use ppc64
	then
		myconf="${myconf} --disable-altivec"
	else
		myconf="${myconf} $(use_enable altivec)"
		use altivec && append-flags -maltivec -mabi=altivec
	fi


	if use xanim
	then
		myconf="${myconf} --with-xanimlibdir=/usr/lib/xanim/mods"
	fi

	if [ -e /dev/.devfsd ]
	then
		myconf="${myconf} --enable-linux-devfs"
	fi

	# support for blinkenlights
	use bl && myconf="${myconf} --enable-bl"

	#leave this in place till the configure/compilation borkage is completely corrected back to pre4-r4 levels.
	# it's intended for debugging so we can get the options we configure mplayer w/, rather then hunt about.
	# it *will* be removed asap; in the meantime, doesn't hurt anything.
	echo "${myconf}" > ${T}/configure-options

	if use custom-cflags
	then
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

	CFLAGS="$CFLAGS" ./configure \
		"--cc=$(tc-getCC)" "--host-cc=$(tc-getBUILD_CC)" \
		--prefix="${EPREFIX}"/usr \
		--confdir="${EPREFIX}"/usr/share/mplayer \
		--datadir="${EPREFIX}"/usr/share/mplayer \
		--enable-largefiles \
		--enable-menu \
		--enable-network --enable-ftp \
		--with-reallibdir=${REALLIBDIR} \
		--disable-faad-external \
		--with-extraincdir="$(gcc-config -L)/include -I${EPREFIX}/usr/include" \
		${myconf} || die

	# we run into problems if -jN > -j1
	# see #86245
	MAKEOPTS="${MAKEOPTS} -j1"

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
		 CONFDIR=${ED}/usr/share/mplayer \
		 DATADIR=${ED}/usr/share/mplayer \
		 MANDIR=${ED}/usr/share/man \
		 install || die "Failed to install MPlayer!"
	einfo "Make install completed"

	dodoc AUTHORS ChangeLog README
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
		newins ${S}/Gui/mplayer/pixmaps/logo.xpm mplayer.xpm
		insinto /usr/share/applications
		doins ${FILESDIR}/mplayer.desktop
	fi
	if ! use truetype || ! use iconv
	then
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

	insinto /etc
	newins ${S}/etc/example.conf mplayer.conf
	dosed -e 's/include =/#include =/' /etc/mplayer.conf
	dosed -e 's/fs=yes/fs=no/' /etc/mplayer.conf
	if use truetype && use iconv
	then
		cat >> ${ED}/etc/mplayer.conf << EOT
fontconfig=1
subfont-osd-scale=4
subfont-text-scale=3
EOT
	fi
	dosym ../../../etc/mplayer.conf /usr/share/mplayer/mplayer.conf

	#mv the midentify script to /usr/bin for emovix.
	cp ${ED}/usr/share/doc/${PF}/TOOLS/midentify ${ED}/usr/bin
	chmod a+x ${ED}/usr/bin/midentify

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

	if use matrox; then
		depmod -a &>/dev/null || :
	fi

	if use alsa ; then
		einfo "For those using alsa, please note the ao driver name is no longer"
		einfo "alsa9x or alsa1x.  It is now just 'alsa' (omit quotes)."
		einfo "The syntax for optional drivers has also changed.  For example"
		einfo "if you use a dmix driver called 'dmixer,' use"
		einfo "ao=alsa:device=dmixer instead of ao=alsa:dmixer"
		einfo "Some users may not need to specify the extra driver with the ao="
		einfo "command."
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

