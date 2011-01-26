# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-opengl/eselect-opengl-1.2.0.ebuild,v 1.1 2011/01/25 19:12:56 scarabeus Exp $

EAPI=3

inherit multilib eutils

DESCRIPTION="Utility to change the OpenGL interface being used"
HOMEPAGE="http://www.gentoo.org/"

# Source:
# http://www.opengl.org/registry/api/glext.h
# http://www.opengl.org/registry/api/glxext.h
GLEXT="67"
GLXEXT="32"

MIRROR="http://dev.gentooexperimental.org/~scarabeus/"
SRC_URI="${MIRROR}/glext.h.${GLEXT}.xz
	${MIRROR}/glxext.h.${GLXEXT}.xz
	${MIRROR}/${P}.tar.xz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="app-arch/xz-utils"
RDEPEND=">=app-admin/eselect-1.2.4"

src_prepare() {
	epatch "${FILESDIR}"/${P}-prefix.patch
}

pkg_postinst() {
	eselect opengl set xorg-x11 --use-old
}

src_install() {
	insinto /usr/share/eselect/modules
	doins opengl.eselect || die
	doman opengl.eselect.5 || die

	# Install global glext.h and glxext.h
	insinto "/usr/$(get_libdir)/opengl/global/include"
	cd "${WORKDIR}"
	newins glext.h.${GLEXT} glext.h || die
	newins glxext.h.${GLXEXT} glxext.h || die
}
