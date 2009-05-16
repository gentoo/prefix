# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/mesa/mesa-7.3-r1.ebuild,v 1.9 2009/05/15 15:12:08 armin76 Exp $

GIT=$([[ ${PV} = 9999* ]] && echo "git")
EGIT_REPO_URI="git://anongit.freedesktop.org/mesa/mesa"

inherit autotools multilib flag-o-matic ${GIT} portability

OPENGL_DIR="xorg-x11"

MY_PN="${PN/m/M}"
MY_P="${MY_PN}-${PV/_/-}"
MY_SRC_P="${MY_PN}Lib-${PV/_/-}"
DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="http://mesa3d.sourceforge.net/"
if [[ $PV = *_rc* ]]; then
	SRC_URI="http://www.mesa3d.org/beta/${MY_SRC_P}.tar.gz"
elif [[ $PV = 9999 ]]; then
	SRC_URI=""
else
	SRC_URI="mirror://sourceforge/mesa3d/${MY_SRC_P}.tar.bz2
	mirror://gentoo/${P}-gentoo-patches-01.tar.bz2"
fi
LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-solaris"
IUSE_VIDEO_CARDS="
	video_cards_intel
	video_cards_mach64
	video_cards_mga
	video_cards_none
	video_cards_r128
	video_cards_radeon
	video_cards_s3virge
	video_cards_savage
	video_cards_sis
	video_cards_sunffb
	video_cards_tdfx
	video_cards_trident
	video_cards_via"
IUSE="${IUSE_VIDEO_CARDS}
	debug
	doc
	pic
	motif
	nptl
	xcb
	kernel_FreeBSD"

RDEPEND="app-admin/eselect-opengl
	dev-libs/expat
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXxf86vm
	x11-libs/libXi
	x11-libs/libXmu
	x11-libs/libXdamage
	>=x11-libs/libdrm-2.4.3
	x11-libs/libICE
	motif? ( x11-libs/openmotif )
	doc? ( app-doc/opengl-manpages )
	!<=x11-base/xorg-x11-6.9"
DEPEND="${RDEPEND}
	!<=x11-proto/xf86driproto-2.0.3
	dev-util/pkgconfig
	x11-misc/makedepend
	x11-proto/inputproto
	x11-proto/xextproto
	!hppa? ( x11-proto/xf86driproto )
	>=x11-proto/dri2proto-1.99.3
	x11-proto/xf86vidmodeproto
	>=x11-proto/glproto-1.4.8
	motif? ( x11-proto/printproto )"

S="${WORKDIR}/${MY_P}"

# Think about: ggi, svga, fbcon, no-X configs

pkg_setup() {
	if use xcb; then
		if ! built_with_use x11-libs/libX11 xcb; then
			msg="You must build libX11 with xcb enabled."
			eerror ${msg}
			die ${msg}
		fi
	fi

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
	if [[ $PV = 9999 ]]; then
		git_src_unpack
	else
		unpack ${A}
	fi
	cd "${S}"

	[[ $PV = 9999 ]] || \
		EPATCH_FORCE="yes" EPATCH_SOURCE="${WORKDIR}/patches" \
		EPATCH_SUFFIX="patch" epatch

	# FreeBSD 6.* doesn't have posix_memalign().
	[[ ${CHOST} == *-freebsd6.* ]] && sed -i -e "s/-DHAVE_POSIX_MEMALIGN//" configure.ac

	# Don't compile debug code with USE=-debug - bug #125004
	if ! use debug; then
	   einfo "Removing DO_DEBUG defs in dri drivers..."
	   find src/mesa/drivers/dri -name *.[hc] -exec egrep -l "\#define\W+DO_DEBUG\W+1" {} \; | xargs sed -i -re "s/\#define\W+DO_DEBUG\W+1/\#define DO_DEBUG 0/" ;
	fi

	eautoreconf
}

src_compile() {
	local myconf

	# This is where we might later change to build xlib/osmesa
	myconf="${myconf} --with-driver=dri"

	# Do we want thread-local storage (TLS)?
	myconf="${myconf} $(use_enable nptl glx-tls)"

	# Configurable DRI drivers
	driver_enable swrast
	driver_enable video_cards_intel i810 i915 i965
	driver_enable video_cards_mach64 mach64
	driver_enable video_cards_mga mga
	driver_enable video_cards_r128 r128
	driver_enable video_cards_radeon radeon r200 r300
	driver_enable video_cards_s3virge s3v
	driver_enable video_cards_savage savage
	driver_enable video_cards_sis sis
	driver_enable video_cards_sunffb ffb
	driver_enable video_cards_tdfx tdfx
	driver_enable video_cards_trident trident
	driver_enable video_cards_via unichrome

	# Set drivers to everything on which we ran driver_enable()
	myconf="${myconf} --with-dri-drivers=${DRI_DRIVERS}"

	# Deactivate assembly code for pic build
	myconf="${myconf} $(use_enable pic asm)"

	# Sparc assembly code is not working
	myconf="${myconf} $(use_enable sparc asm)"

	myconf="${myconf} --disable-glut"

	myconf="${myconf} --without-demos"

	myconf="${myconf} $(use_enable xcb)"

	# Get rid of glut includes
	rm -f "${S}"/include/GL/glut*h

	myconf="${myconf} $(use_enable motif glw)"

	econf ${myconf} || die
	emake || die
}

src_install() {
	dodir /usr
	emake \
		DESTDIR="${D}" \
		install || die "Installation failed"

	if ! use motif; then
		rm "${ED}"/usr/include/GL/GLwMDrawA.h
	fi

	# Don't install private headers
	rm -f "${ED}"/usr/include/GL/GLw*P.h

	fix_opengl_symlinks
	dynamic_libgl_install

	# Install libtool archives
	insinto /usr/$(get_libdir)
	# (#67729) Needs to be lib, not $(get_libdir)
	doins "${FILESDIR}"/lib/libGLU.la
	sed -e "s:\${libdir}:$(get_libdir):g" "${FILESDIR}"/lib/libGL.la \
		> "${ED}"/usr/$(get_libdir)/opengl/xorg-x11/lib/libGL.la

	# On *BSD libcs dlopen() and similar functions are present directly in
	# libc.so and does not require linking to libdl. portability eclass takes
	# care of finding the needed library (if needed) witht the dlopen_lib
	# function.
	sed -i -e 's:-ldl:'$(dlopen_lib)':g' \
		"${ED}"/usr/$(get_libdir)/libGLU.la \
		"${ED}"/usr/$(get_libdir)/opengl/xorg-x11/lib/libGL.la

	# libGLU doesn't get the plain .so symlink either
	#dosym libGLU.so.1 /usr/$(get_libdir)/libGLU.so

	# Figure out why libGL.so.1.5 is built (directfb), and why it's linked to
	# as the default libGL.so.1
}

pkg_postinst() {
	switch_opengl_implem
}

fix_opengl_symlinks() {
	# Remove invalid symlinks
	local LINK
	for LINK in $(find "${ED}"/usr/$(get_libdir) \
		-name libGL\.* -type l); do
		rm -f ${LINK}
	done
	# Create required symlinks
	if [[ ${CHOST} == *-freebsd* ]]; then
		# FreeBSD doesn't use major.minor versioning, so the library is only
		# libGL.so.1 and no libGL.so.1.2 is ever used there, thus only create
		# libGL.so symlink and leave libGL.so.1 being the real thing
		dosym libGL.so.1 /usr/$(get_libdir)/libGL.so
	else
		dosym libGL.so.1.2 /usr/$(get_libdir)/libGL.so
		dosym libGL.so.1.2 /usr/$(get_libdir)/libGL.so.1
	fi
}

dynamic_libgl_install() {
	# next section is to setup the dynamic libGL stuff
	ebegin "Moving libGL and friends for dynamic switching"
		dodir /usr/$(get_libdir)/opengl/${OPENGL_DIR}/{lib,extensions,include}
		local x=""
		for x in "${ED}"/usr/$(get_libdir)/libGL.so* \
			"${ED}"/usr/$(get_libdir)/libGL.la \
			"${ED}"/usr/$(get_libdir)/libGL.a; do
			if [ -f ${x} -o -L ${x} ]; then
				# libGL.a cause problems with tuxracer, etc
				mv -f ${x} "${ED}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/lib
			fi
		done
		# glext.h added for #54984
		for x in "${ED}"/usr/include/GL/{gl.h,glx.h,glext.h,glxext.h}; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f ${x} "${ED}"/usr/$(get_libdir)/opengl/${OPENGL_DIR}/include
			fi
		done
	eend 0
}

switch_opengl_implem() {
		# Switch to the xorg implementation.
		# Use new opengl-update that will not reset user selected
		# OpenGL interface ...
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
