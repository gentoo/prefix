# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/motif-config/motif-config-0.10.ebuild,v 1.3 2006/12/26 05:00:09 vapier Exp $

EAPI="prefix"

inherit eutils multilib

DESCRIPTION="Utility to change the default Motif library"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

DEPEND="!<x11-libs/openmotif-2.1.30-r13
	!=x11-libs/openmotif-2.2.2*
	!=x11-libs/openmotif-2.2.3
	!=x11-libs/openmotif-2.2.3-r1
	!=x11-libs/openmotif-2.2.3-r2
	!=x11-libs/openmotif-2.2.3-r3
	!=x11-libs/openmotif-2.2.3-r4
	!=x11-libs/openmotif-2.2.3-r5
	!=x11-libs/openmotif-2.2.3-r6

	!<x11-libs/lesstif-0.93.94-r4
	!=x11-libs/lesstif-0.93.97
	!=x11-libs/lesstif-0.94.0*"
RDEPEND="${DEPEND}
	app-shells/bash"

src_unpack() {
	cd "${T}"
	cp "${FILESDIR}"/${P} .
	cp "${FILESDIR}"/system.mwmrc .
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify ${P} system.mwmrc
}

src_install() {
	newbin "${T}"/${P} motif-config || die
	dosed "s:@@LIBDIR@@:$(get_libdir):g" /usr/bin/motif-config

	# for profile
	dodir /usr/$(get_libdir)/motif
	keepdir /usr/$(get_libdir)/motif

	# bitmaps
	#dodir /usr/include/X11/bitmaps
	#tar -xjf ${FILESDIR}/bitmaps.tbz2 -C ${ED}/usr/include/X11/bitmaps
	# bindings
	#dodir /usr/$(get_libdir)/X11/bindings
	#tar -xjf ${FILESDIR}/bindings.tbz2 -C ${ED}/usr/$(get_libdir)/X11/bindings

	# mwm default config
	insinto /etc/X11/app-defaults
	doins "${FILESDIR}"/Mwm.defaults

	insinto /etc/X11/mwm
	doins "${T}"/system.mwmrc

	dodir /usr/$(get_libdir)/X11
	dosym /etc/X11/mwm /usr/$(get_libdir)/X11/mwm
}

pkg_setup() {
	# clean up cruft left over by old versions
	removed=no
	has_version =x11-libs/openmotif-2.1.30* \
		|| ( rm -f /usr/$(get_libdir)/motif/openmotif-2.1; \
		rm -fR /usr/include/openmotif-2.1; \
		rm -fR /usr/$(get_libdir)/openmotif-2.1;
		removed=yes )
	has_version =x11-libs/openmotif-2.2.3* \
		|| ( rm -f /usr/$(get_libdir)/motif/openmotif-2.2; \
		rm -fR /usr/include/openmotif-2.2; \
		rm -fR /usr/$(get_libdir)/openmotif-2.2;
		removed=yes )
	has_version =x11-libs/lesstif-0.93.94* \
		|| ( rm -f /usr/$(get_libdir)/motif/lesstif-1.2; \
		rm -fR /usr/include/lesstif-1.2; \
		rm -fR /usr/$(get_libdir)/lesstif-1.2;
		removed=yes )
	has_version =x11-libs/lesstif-0.94* \
		|| ( rm -f /usr/$(get_libdir)/motif/lesstif-2.1; \
		rm -fR /usr/include/lesstif-2.1; \
		rm -fR /usr/$(get_libdir)/openmotif-2.1;
		removed=yes )

	if [ "$removed" = "yes" ]; then
		rm -fR /usr/include/Xm;
		rm -fR /usr/include/uil;
		rm -fR /usr/include/Mrm;
	fi
}
