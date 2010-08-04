# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/mesa/mesa-7.8.2.ebuild,v 1.8 2010/08/03 19:08:35 scarabeus Exp $

EAPI=3

EGIT_REPO_URI="git://anongit.freedesktop.org/mesa/mesa"

if [[ ${PV} = 9999* ]]; then
	GIT_ECLASS="git"
	EXPERIMENTAL="true"
fi

inherit autotools multilib flag-o-matic toolchain-funcs ${GIT_ECLASS} portability

OPENGL_DIR="xorg-x11"

MY_PN="${PN/m/M}"
MY_P="${MY_PN}-${PV/_/-}"
MY_SRC_P="${MY_PN}Lib-${PV/_/-}"
DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="http://mesa3d.sourceforge.net/"

#SRC_PATCHES="mirror://gentoo/${P}-gentoo-patches-01.tar.bz2"
if [[ $PV = 9999* ]]; then
	SRC_URI="${SRC_PATCHES}"
else
	SRC_URI="ftp://ftp.freedesktop.org/pub/mesa/${PV}/${MY_SRC_P}.tar.bz2
		${SRC_PATCHES}"
fi

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"

VIDEO_CARDS="intel mach64 mga none nouveau r128 radeon radeonhd savage sis svga tdfx via"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS}
	debug +gallium motif +nptl pic selinux +xcb kernel_FreeBSD"

# keep correct libdrm and dri2proto dep
# keep blocks in rdepend for binpkg
RDEPEND="
	!<x11-base/xorg-server-1.7
	!<=x11-proto/xf86driproto-2.0.3
	>=app-admin/eselect-opengl-1.1.1-r2
	dev-libs/expat
	>=x11-libs/libdrm-2.4.19
	gallium? (
		video_cards_nouveau? ( <x11-libs/libdrm-2.4.21 )
	)
	x11-libs/libICE
	x11-libs/libX11[xcb?]
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXmu
	x11-libs/libXxf86vm
	motif? ( x11-libs/openmotif )
"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	x11-misc/makedepend
	>=x11-proto/dri2proto-2.2
	>=x11-proto/glproto-1.4.11
	x11-proto/inputproto
	>=x11-proto/xextproto-7.0.99.1
	x11-proto/xf86driproto
	x11-proto/xf86vidmodeproto
"

S="${WORKDIR}/${MY_P}"

# It is slow without texrels, if someone wants slow
# mesa without texrels +pic use is worth shot
QA_EXECSTACK="usr/lib*/opengl/xorg-x11/lib/libGL.so*"
QA_WX_LOAD="usr/lib*/opengl/xorg-x11/lib/libGL.so*"

# Think about: ggi, svga, fbcon, no-X configs

pkg_setup() {
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
	# Solaris needs some recent POSIX stuff in our case
	if [[ ${CHOST} == *-solaris* ]] ; then
		sed -i -e "s/-DSVR4/-D_POSIX_C_SOURCE=200112L/" configure.ac || die
		sed -i -e 's/uint/unsigned int/g' src/egl/drivers/glx/egl_glx.c || die
	fi

	# In order for mesa to complete it's build process we need to use a tool
	# that it compiles. When we cross compile this clearly does not work
	# so we require mesa to be built on the host system first. -solar
	if tc-is-cross-compiler; then
		sed -i -e "s#^GLSL_CL = .*\$#GLSL_CL = glsl-compile#g" \
			"${S}"/src/mesa/shader/slang/library/Makefile || die
	fi

	eautoreconf
}

src_configure() {
	local myconf r600

	# Configurable DRI drivers
	driver_enable swrast
	driver_enable video_cards_intel i810 i915 i965
	driver_enable video_cards_mach64 mach64
	driver_enable video_cards_mga mga
	driver_enable video_cards_r128 r128
	# ATI has two implementations as video_cards
	driver_enable video_cards_radeon radeon r200 r300 r600
	driver_enable video_cards_radeonhd r300 r600
	driver_enable video_cards_savage savage
	driver_enable video_cards_sis sis
	driver_enable video_cards_tdfx tdfx
	driver_enable video_cards_via unichrome

	myconf="${myconf} $(use_enable gallium)"
	if use gallium; then
		elog "You have enabled gallium infrastructure."
		elog "This infrastructure currently support these drivers:"
		elog "    Intel: works only i915."
		elog "    Nouveau: Support for nVidia NV30 and later cards."
		elog "    Radeon: Newest implementation of r300-r500 driver."
		elog "    Svga: VMWare Virtual GPU driver."
		echo
		myconf="${myconf}
			--with-state-trackers=glx,dri,egl
			$(use_enable video_cards_svga gallium-svga)
			$(use_enable video_cards_nouveau gallium-nouveau)
			$(use_enable video_cards_intel gallium-intel)"
		if use video_cards_radeon || use video_cards_radeonhd; then
			myconf="${myconf} --enable-gallium-radeon"
		else
			myconf="${myconf} --disable-gallium-radeon"
		fi
	else
		if use video_cards_nouveau || use video_cards_svga; then
			elog "SVGA and nouveau drivers are available only via gallium interface."
			elog "Enable gallium useflag if you want to use them."
		fi
	fi

	# --with-driver=dri|xlib|osmesa || do we need osmesa?
	econf \
		--disable-option-checking \
		--with-driver=dri \
		--disable-glut \
		--without-demos \
		$(use_enable debug) \
		$(use_enable motif glw) \
		$(use_enable motif) \
		$(use_enable nptl glx-tls) \
		$(use_enable xcb) \
		$(use_enable !pic asm) \
		--with-dri-drivers=${DRI_DRIVERS} \
		${myconf}
}

src_install() {
	emake DESTDIR="${D}" install || die "Installation failed"

	# Save the glsl-compiler for later use
	if ! tc-is-cross-compiler; then
		dodir /usr/bin/
		cp "${S}"/src/glsl/apps/compile "${ED}"/usr/bin/glsl-compile \
			|| die "failed to copy the glsl compiler."
	fi
	# Remove redundant headers
	# GLUT thing
	rm -f "${ED}"/usr/include/GL/glut*.h || die "Removing glut include failed."
	# Glew includes
	rm -f "${ED}"/usr/include/GL/{glew,glxew,wglew}.h \
		|| die "Removing glew includes failed."

	# Move libGL and others from /usr/lib to /usr/lib/opengl/blah/lib
	# because user can eselect desired GL provider.
	ebegin "Moving libGL and friends for dynamic switching"
		dodir /usr/$(get_libdir)/opengl/${OPENGL_DIR}/{lib,extensions,include}
		local x
		for x in "${ED}"/usr/$(get_libdir)/libGL.{a,so*}; do
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
			DRI_DRIVERS+=",$1"
			;;
		*)
			if use $1; then
				shift
				for i in $@; do
					DRI_DRIVERS+=",${i}"
				done
			fi
			;;
	esac
}
