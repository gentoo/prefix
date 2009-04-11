# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

DESCRIPTION="Links to Apple's OpenGL Framework"
HOMEPAGE="http://www.apple.com/"
LICENSE="as-is"
KEYWORDS="~ppc-macos ~x86-macos"
SLOT=0
IUSE="doc"

DEPEND=">=app-admin/eselect-opengl-1.0.6-r01.1
	doc? ( app-doc/opengl-manpages )
	x11-proto/glproto"
RDEPEND="${DEPEND}"

APPLE_OPENGL_DIR="/System/Library/Frameworks/OpenGL.framework"
X11_OPENGL_DIR="/usr/X11R6"

src_install() {
	dodir /usr/lib/opengl/${PN}/{lib,include}
	dodir /usr/include/GL

	cd "${ED}"/usr/lib/opengl/${PN}/include
	ln -s "${APPLE_OPENGL_DIR}"/Headers/gl.h
	ln -s "${APPLE_OPENGL_DIR}"/Headers/glext.h
	ln -s "${X11_OPENGL_DIR}"/include/GL/glx.h
	ln -s "${X11_OPENGL_DIR}"/include/GL/glxext.h
	ln -s "${X11_OPENGL_DIR}"/include/GL/glxmd.h
	ln -s "${X11_OPENGL_DIR}"/include/GL/glxproto.h
	ln -s "${X11_OPENGL_DIR}"/include/GL/glxtokens.h
	cd "${ED}"/usr/lib/opengl/${PN}/lib
	ln -s "${APPLE_OPENGL_DIR}"/Libraries/libGL.dylib
	# this is dirty, and questionable if it's useful as well
	ln -s "${X11_OPENGL_DIR}"/lib/libGL.1.2.dylib

	cd "${ED}"/usr/include/GL
	ln -s "${APPLE_OPENGL_DIR}"/Headers/glu.h
	ln -s "${X11_OPENGL_DIR}"/include/GL/GLwDrawA.h
	ln -s "${X11_OPENGL_DIR}"/include/GL/osmesa.h
	cd "${ED}"/usr/lib
	ln -s "${APPLE_OPENGL_DIR}"/Libraries/libGLU.dylib
	# this is dirty, and questionable if it's useful as well
	ln -s "${X11_OPENGL_DIR}"/lib/libGLU.1.3.dylib
	ln -s "${X11_OPENGL_DIR}"/lib/libGLw.a
}

pkg_postinst() {
	# Set as default VM if none exists
	eselect opengl set ${PN}

	elog "Note: you're using your OSX (pre-)installed OpenGL Framework"
}
