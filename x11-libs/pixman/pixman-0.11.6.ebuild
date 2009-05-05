# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/pixman/pixman-0.11.6.ebuild,v 1.4 2009/05/04 15:17:31 ssuominen Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

inherit x-modular

DESCRIPTION="Low-level pixel manipulation routines"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="altivec mmx sse2"

pkg_setup() {
	CONFIGURE_OPTIONS="$(use_enable altivec vmx) $(use_enable mmx)
	$(use_enable sse2) --disable-gtk"
}
