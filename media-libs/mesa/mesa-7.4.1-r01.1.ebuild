# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/mesa/mesa-7.4.1-r1.ebuild,v 1.3 2009/05/02 20:44:06 scarabeus Exp $

EAPI=2

EGIT_REPO_URI="git://anongit.freedesktop.org/mesa/mesa"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git"
	EXPERIMENTAL="true"
	IUSE_VIDEO_CARDS_UNSTABLE="video_cards_nouveau"
	IUSE_UNSTABLE="gallium"
	# User can also specify branch by simply adding MESA_LIVE_BRANCH="blesmrt"
	# to the make.conf, where blesmrt is desired branch.
	[[ -z ${MESA_LIVE_BRANCH} ]] || EGIT_BRANCH="${MESA_LIVE_BRANCH}"
fi

inherit autotools multilib flag-o-matic ${GIT_ECLASS} portability

OPENGL_DIR="xorg-x11"

MY_PN="${PN/m/M}"
MY_P="${MY_PN}-${PV/_/-}"
MY_SRC_P="${MY_PN}Lib-${PV/_/-}"
DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="http://mesa3d.sourceforge.net/"

SRC_PATCHES="mirror://gentoo/${P}-gentoo-patches-01.tar.bz2"
if [[ $PV = *_rc* ]]; then
	SRC_URI="http://www.mesa3d.org/beta/${MY_SRC_P}.tar.gz
		${SRC_PATCHES}"
elif [[ $PV = 9999* ]]; then
	SRC_URI="${SRC_PATCHES}"
else
	SRC_URI="mirror://sourceforge/mesa3d/${MY_SRC_P}.tar.bz2
		${SRC_PATCHES}"
fi

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-solaris"

IUSE_VIDEO_CARDS="${IUSE_VIDEO_CARDS_UNSTABLE}
	video_cards_intel
	video_cards_mach64
	video_cards_mga
	video_cards_none
	video_cards_r128
	video_cards_radeon
	video_cards_radeonhd
	video_cards_s3virge
	video_cards_savage
	video_cards_sis
	video_cards_sunffb
	video_cards_tdfx
	video_cards_trident
	video_cards_via"
IUSE="${IUSE_VIDEO_CARDS} ${IUSE_UNSTABLE}
	debug doc motif nptl pic xcb kernel_FreeBSD"

# keep correct libdrm and dri2proto dep
# keep blocks in rdepend for binpkg
RDEPEND="!<=x11-base/xorg-x11-6.9
	!<=x11-proto/xf86driproto-2.0.3
	app-admin/eselect-opengl
	dev-libs/expat
	>=x11-libs/libdrm-2.4.6
	x11-libs/libICE
	x11-libs/libX11[xcb?]
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXmu
	x11-libs/libXxf86vm
	motif? ( x11-libs/openmotif )
	doc? ( app-doc/opengl-manpages )
"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	x11-misc/makedepend
	>=x11-proto/dri2proto-1.99.3
	>=x11-proto/glproto-1.4.8
	x11-proto/inputproto
	x11-proto/xextproto
	x11-proto/xf86vidmodeproto
	!hppa? ( x11-proto/xf86driproto )
	motif? ( x11-proto/printproto )
"
# glew depend on mesa and it is needed in runtime
PDEPEND=">=media-libs/glew-1.5.1"

S="${WORKDIR}/${MY_P}"

# Think about: ggi, svga, fbcon, no-X configs

pkg_setup() {
	if use debug; then
		append-flags -g
	fi

	# gcc 4.2 has buggy ivopts
	if [[ $(gcc-version) = "4.2" ]]; then
		append-flags -fno-ivopts
	fi

	# recommended by upstream
	append-flags -ffast-math
}

src_unpack() {
	[[ $PV = 9999* ]] && git_src_unpack || unpack ${A}
}

src_prepare() {
	# apply patches
	if [[ ${PV} != 9999* && -n ${SRC_PATCHES} ]]; then
		EPATCH_FORCE="yes" \
		EPATCH_SOURCE="${WORKDIR}/patches" \
		EPATCH_SUFFIX="patch" \
		epatch
	fi
	# FreeBSD 6.* doesn't have posix_memalign().
	[[ ${CHOST} == *-freebsd6.* ]] && \
		sed -i -e "s/-DHAVE_POSIX_MEMALIGN//" configure.ac

	eautoreconf
}

src_configure() {
	local myconf

	# Configurable DRI drivers
	driver_enable swrast
	driver_enable video_cards_intel i810 i915 i965
	driver_enable video_cards_mach64 mach64
	driver_enable video_cards_mga mga
	driver_enable video_cards_r128 r128
	# ATI has two implementations as video_cards
	driver_enable video_cards_radeon radeon r200 r300
	driver_enable video_cards_radeonhd r300
	driver_enable video_cards_s3virge s3v
	driver_enable video_cards_savage savage
	driver_enable video_cards_sis sis
	driver_enable video_cards_sunffb ffb
	driver_enable video_cards_tdfx tdfx
	driver_enable video_cards_trident trident
	driver_enable video_cards_via unichrome

	# all live (experimental) stuff is wrapped around with experimental variable
	# so the users cant get to this parts even with enabled useflags (downgrade
	# from live to stable for example)
	if [[ -n ${EXPERIMENTAL} ]]; then
		# nouveau works only with gallium and intel, radeon, radeonhd can use
		# gallium as alternative implementation (NOTE: THIS IS EXPERIMENTAL)
		if use video_cards_nouveau && ! use gallium ; then
			elog "Nouveau driver is available only via gallium interface."
			elog "Enable gallium useflag if you want to use nouveau."
			echo
		fi
		# state trackers, for now enable the one i want
		# think about this bit more...
		myconf="${myconf} $(use_enable gallium)"
		if use gallium; then
			elog "Warning gallium interface is highly experimental so use"
			elog "it only if you feel really really brave."
			elog
			elog "Intel: works only i915."
			elog "Nouveau: only available implementation, so no other choice"
			elog "Radeon: not working, disabled."
			echo
			myconf="${myconf}
				--with-state-trackers=glx,dri,egl
				$(use_enable video_cards_nouveau gallium-nouveau)
				$(use_enable video_cards_intel gallium-intel)"
				#$(use_enable video_cards_radeon gallium-radeon)
				#$(use_enable video_cards_radeonhd gallium-radeon)"
		fi
	fi

	# Deactivate assembly code for pic build
	# Sparc assembly code is not working
	myconf="${myconf} $(use_enable !pic asm)"
	myconf="${myconf} $(use_enable !sparc asm)"

	# --with-driver=dri|xlib|osmesa ; might get changed later to something
	# else than dri
	econf \
		--with-driver=dri \
		--disable-glut \
		--without-demos \
		$(use_enable debug) \
		$(use_enable motif glw) \
		$(use_enable motif) \
		$(use_enable nptl glx-tls) \
		$(use_enable xcb) \
		--with-dri-drivers=${DRI_DRIVERS} \
		${myconf}
}

src_install() {
	dodir /usr
	emake DESTDIR="${D}" install || die "Installation failed"

	# Remove redundant headers
	# GLUT thing
	rm -f "${ED}"/usr/include/GL/glut*.h || die "Removing glut include failed."
	# Glew headers
	rm -f "${ED}"/usr/include/GL/{glew,glxew,wglew}.h \
		|| die "Removing glew includes failed."

	# Move libGL and others from /usr/lib to /usr/lib/opengl/blah/lib
	# because user can eselect desired GL provider.
	ebegin "Moving libGL and friends for dynamic switching"
		dodir /usr/$(get_libdir)/opengl/${OPENGL_DIR}/{lib,extensions,include}
		local x
		for x in "${ED}"/usr/$(get_libdir)/libGL.{la,a,so*}; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f ${x} "${ED}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/lib \
					|| die "Failed to move ${x}"
			fi
		done
		for x in "${ED}"/usr/include/GL/{gl.h,glx.h,glext.h,glxext.h}; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f ${x} "${ED}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/include \
					|| die "Failed to move ${x}"
			fi
		done
	eend $?

	# Install libtool archives
	insinto /usr/$(get_libdir)
	# Should this use the -L/usr/lib instead of -L/usr/$(get_libdir)?
	# Please confirm and update this comment or the file.
	sed -e "s:/usr/lib:${EPREFIX}/usr/lib:g" \
		"${FILESDIR}"/lib/libGLU.la > "${T}"/libGLU.la
	doins "${T}"/libGLU.la || die "doins libGLU.la failed"
	sed \
		-e "s:/usr/\${libdir}:${EPREFIX}/usr/$(get_libdir):g" \
		"${FILESDIR}"/lib/libGL.la \
		> "${ED}"/usr/$(get_libdir)/opengl/xorg-x11/lib/libGL.la

	# On *BSD libcs dlopen() and similar functions are present directly in
	# libc.so and does not require linking to libdl. portability eclass takes
	# care of finding the needed library (if needed) witht the dlopen_lib
	# function.
	sed -i \
		-e 's:-ldl:'$(dlopen_lib)':g' \
		"${ED}"/usr/$(get_libdir)/{libGLU.la,opengl/xorg-x11/lib/libGL.la} \
		|| die "sed dlopen failed"
}

pkg_postinst() {
	# Switch to the xorg implementation.
	echo
	eselect opengl set --use-old ${OPENGL_DIR}
}

# $1 - VIDEO_CARDS flag
# other args - names of DRI drivers to enable
driver_enable() {
	case $# in
		# for enabling unconditionally
		1)
			DRI_DRIVERS="${DRI_DRIVERS},$1"
			;;
		*)
			if use $1; then
				shift
				for i in $@; do
					DRI_DRIVERS="${DRI_DRIVERS},${i}"
				done
			fi
			;;
	esac
}
