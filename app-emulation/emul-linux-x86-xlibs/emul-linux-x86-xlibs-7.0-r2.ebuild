# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emulation/emul-linux-x86-xlibs/emul-linux-x86-xlibs-7.0-r2.ebuild,v 1.1 2006/08/19 17:46:35 herbs Exp $

EAPI="prefix"

inherit eutils multilib

DESCRIPTION="X11R6 libraries for emulation of 32bit x86 on amd64"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/emul-linux-x86-xlibs-${PVR}.tar.bz2
		video_cards_i810? ( mirror://gentoo/emul-linux-x86-xlibs-i810_dri-${PV}.tar.bz2 )
		video_cards_mach64? ( mirror://gentoo/emul-linux-x86-xlibs-ati_dri-${PV}.tar.bz2 )
		video_cards_mga? ( mirror://gentoo/emul-linux-x86-xlibs-mga_dri-${PV}.tar.bz2 )
		video_cards_r128? ( mirror://gentoo/emul-linux-x86-xlibs-ati_dri-${PV}.tar.bz2 )
		video_cards_radeon? ( mirror://gentoo/emul-linux-x86-xlibs-ati_dri-${PV}.tar.bz2 )
		video_cards_s3virge? ( mirror://gentoo/emul-linux-x86-xlibs-s3virge_dri-${PV}.tar.bz2 )
		video_cards_savage? ( mirror://gentoo/emul-linux-x86-xlibs-savage_dri-${PV}.tar.bz2 )
		video_cards_sis? ( mirror://gentoo/emul-linux-x86-xlibs-sis_dri-${PV}.tar.bz2 )
		video_cards_tdfx? ( mirror://gentoo/emul-linux-x86-xlibs-tdfx_dri-${PV}.tar.bz2 )
		video_cards_trident? ( mirror://gentoo/emul-linux-x86-xlibs-trident_dri-${PV}.tar.bz2 )
		video_cards_via? ( mirror://gentoo/emul-linux-x86-xlibs-via_dri-${PV}.tar.bz2 )"


LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-* amd64"

IUSE_VIDEO_CARDS="
	video_cards_i810
	video_cards_mach64
	video_cards_mga
	video_cards_r128
	video_cards_radeon
	video_cards_s3virge
	video_cards_savage
	video_cards_sis
	video_cards_tdfx
	video_cards_trident
	video_cards_via"

IUSE="opengl ${IUSE_VIDEO_CARDS}"

DEPEND=""

RDEPEND="opengl? ( app-admin/eselect-opengl )
	 virtual/libc
	 >=app-emulation/emul-linux-x86-baselibs-2.5"

S=${WORKDIR}

RESTRICT="nostrip"

pkg_preinst() {
	# Check for bad symlink before installing, bug 84441.
	if [ -L "${EPREFIX}"/emul/linux/x86/usr/lib/X11 ]; then
		rm -f "${EPREFIX}"/emul/linux/x86/usr/lib/X11
	fi
}

src_install() {
	dodir /
	cp -RPvf ${WORKDIR}/* ${ED}/

	local libdir="lib32"
	if has_multilib_profile; then
		libdir=$(get_abi_LIBDIR x86)
	fi

	dodir /usr/${libdir}/opengl
	dosym /emul/linux/x86/usr/lib/opengl/xorg-x11 /usr/${libdir}/opengl/xorg-x11
}

pkg_postinst() {
	#update GL symlinks
	if use opengl ; then
		"${EPREFIX}"/usr/bin/eselect opengl set --use-old
	fi
}

