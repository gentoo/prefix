# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-apps/xmodmap/xmodmap-1.0.3.ebuild,v 1.6 2008/02/05 11:36:37 corsair Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="utility for modifying keymaps and pointer button mappings in X"

KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris ~x86-winnt"

RDEPEND="x11-libs/libX11"
DEPEND="${RDEPEND}"

src_compile() {
	# on winnt, strncasecmp is there, but as static function in a
	# header file, which - of course - makes the link test fail which
	# does not include that file.
	[[ ${CHOST} == *-winnt* ]] && export ac_cv_func_strncasecmp=yes

	x-modular_src_compile || die "src_compile failed"
}

