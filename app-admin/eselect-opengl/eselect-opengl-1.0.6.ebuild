# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/app-admin/eselect-opengl/eselect-opengl-1.0.6.ebuild,v 1.3 2007/12/27 23:41:51 eradicator Exp $

EAPI="prefix"

inherit multilib

DESCRIPTION="Utility to change the OpenGL interface being used"
HOMEPAGE="http://www.gentoo.org/"

# Source:
# http://oss.sgi.com/projects/ogl-sample/ABI/glext.h
# http://oss.sgi.com/projects/ogl-sample/ABI/glxext.h

GLEXT="29"
GLXEXT="11"

SRC_URI="mirror://gentoo/glext.h-${GLEXT}.bz2
	 mirror://gentoo/glxext.h-${GLXEXT}.bz2
	 mirror://gentoo/opengl.eselect-${PV}.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux"
IUSE=""
EMULTILIB_PKG="true"

DEPEND="app-arch/bzip2"
RDEPEND=">=app-admin/eselect-1.0.5"

S=${WORKDIR}

src_unpack() {
	unpack ${A}

	mv opengl.eselect-${PV} opengl.eselect
	mv glext.h-${GLEXT} glext.h
	mv glxext.h-${GLXEXT} glxext.h
}

pkg_preinst() {
	# It needs to be before 04multilib
	[[ -f "${EROOT}/etc/env.d/09opengl" ]] && mv ${EROOT}/etc/env.d/09opengl ${EROOT}/etc/env.d/03opengl

	OABI="${ABI}"
	for ABI in $(get_install_abis); do
		if [[ -e "${EROOT}/usr/$(get_libdir)/opengl/xorg-x11/lib/libMesaGL.so" ]]
		then
			einfo "Removing libMesaGL.so from xorg-x11 profile. See bug #47598."
			rm -f "${EROOT}/usr/$(get_libdir)/opengl/xorg-x11/lib/libMesaGL.so"
		fi
		if [[ -e "${EROOT}/usr/$(get_libdir)/libMesaGL.so" ]]
		then
			einfo "Removing libMesaGL.so from /usr/$(get_libdir).  See bug #47598."
			rm -f "${EROOT}/usr/$(get_libdir)/libMesaGL.so"
		fi

		for f in "${EROOT}/usr/$(get_libdir)"/libGL.so.* "${EROOT}/usr/$(get_libdir)"/libGLcore.so.* "${EROOT}/usr/$(get_libdir)"/libnvidia-tls* "${EROOT}/usr/$(get_libdir)"/tls/libnvidia-tls* ; do
			[[ -e ${f} ]] && rm -f "${f}"
		done
	done
	ABI="${OABI}"
	unset OABI
}

pkg_postinst() {
	local impl="$(eselect opengl show)"
	if [[ -n "${impl}" ]] ; then
		eselect opengl set "${impl}"
	fi
}

src_install() {
	insinto /usr/share/eselect/modules
	doins opengl.eselect

	# Install default glext.h
	insinto "/usr/$(get_libdir)/opengl/global/include"
	doins "${WORKDIR}/glext.h" || die
	doins "${WORKDIR}/glxext.h" || die
}
