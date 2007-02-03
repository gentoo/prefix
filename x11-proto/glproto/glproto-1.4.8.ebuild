# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/www/viewcvs.gentoo.org/raw_cvs/gentoo-x86/x11-proto/glproto/glproto-1.4.8.ebuild,v 1.7 2006/12/01 18:14:36 gustavoz Exp $

EAPI="prefix"

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

OPENGL_DIR="xorg-x11"

DESCRIPTION="X.Org GL protocol headers"

KEYWORDS="~amd64 ~ia64 ~x86 ~x86-macos"

RDEPEND=""
DEPEND="${RDEPEND}
	app-admin/eselect-opengl"

src_install() {
	x-modular_src_install

	dynamic_libgl_install
}

pkg_postinst() {
	x-modular_pkg_postinst

	switch_opengl_implem
}

dynamic_libgl_install() {
	# next section is to setup the dynamic libGL stuff
	ebegin "Moving GL files for dynamic switching"
		dodir /usr/$(get_libdir)/opengl/${OPENGL_DIR}/include
		local x=""
		# glext.h added for #54984
		for x in ${ED}/usr/include/GL/{glxtokens.h,glxmd.h,glxproto.h}; do
			if [ -f ${x} -o -L ${x} ]; then
				mv -f ${x} ${ED}/usr/$(get_libdir)/opengl/${OPENGL_DIR}/include
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
