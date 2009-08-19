# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-doc/opengl-manpages/opengl-manpages-20001215.ebuild,v 1.15 2009/07/14 09:43:26 flameeyes Exp $

DESCRIPTION="Man pages for OpenGL"
HOMEPAGE="http://www.opengl.org/documentation/specs/"
RESTRICT="mirror"
SRC_URI="ftp://ftp.sgi.com/opengl/doc/mangl.tar.Z \
	ftp://ftp.sgi.com/opengl/doc/manglu.tar.Z \
	ftp://ftp.sgi.com/opengl/doc/manglx.tar.Z"
S="${WORKDIR}/release/xc/doc/man/GL"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	x11-misc/imake
	>=x11-misc/xorg-cf-files-1.0.1-r2"

src_compile() {
	for x in ${S}/*; do
		cd ${x}
		xmkmf || die "xmkmf failed"
		emake || die "make failed"
	done
}

src_install() {
	for x in ${S}/*; do
		cd ${x}
		emake DESTDIR="${D}" install || die "make install failed"
	done
	dohtml -r ${WORKDIR}/release/xc/doc/hardcopy/GL/html/*
}
