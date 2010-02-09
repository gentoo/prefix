# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-opengl/eselect-opengl-1.1.1-r2.ebuild,v 1.6 2010/02/06 18:06:47 armin76 Exp $

EAPI="2"

inherit multilib eutils

DESCRIPTION="Utility to change the OpenGL interface being used"
HOMEPAGE="http://www.gentoo.org/"

# Source:
# http://www.opengl.org/registry/api/glext.h
# http://www.opengl.org/registry/api/glxext.h
GLEXT="56"
GLXEXT="25"

MIRROR="http://dev.gentooexperimental.org/~scarabeus/"
SRC_URI="${MIRROR}/glext.h.${GLEXT}.bz2
	${MIRROR}/glxext.h.${GLXEXT}.bz2
	${MIRROR}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="app-arch/bzip2"
RDEPEND=">=app-admin/eselect-1.2.4"

src_prepare() {
	epatch "${FILESDIR}"/${P}-soname-copy-for-prefix.patch 

	sed -i -e "/^\(ENV_FILE=\|PREFIX=\|DST_PREFIX=\)/s:ROOT}:ROOT}${EPREFIX}:" \
		opengl.eselect || die

	# fix la FAIL
	sed -i -e 's/{la}/la/' opengl.eselect || die
}

pkg_postinst() {
	local impl="$(eselect opengl show)"
	if [[ -n "${impl}"  && "${impl}" != '(none)' ]] ; then
		eselect opengl set "${impl}"
	fi

	# info about removal of .la file
	einfo
	elog "eselect-opengl since version 1.0.9 strips the libGL.la file."
	elog "This file was broken by design and thus removed."
	elog "For fixing all sort of configure issues please run:"
	elog "  lafilefixer --justfixit"
	elog "or run revdep-rebuild if you update from any older release."
	elog "(lafilefixer package can be found as dev-util/lafilefixer)"
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
