# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/ladspa-sdk/ladspa-sdk-1.12-r2.ebuild,v 1.21 2012/06/08 23:51:44 zmedico Exp $

inherit eutils multilib

MY_PN=${PN/-/_}
MY_P=${MY_PN}_${PV}

DESCRIPTION="The Linux Audio Developer's Simple Plugin API"
HOMEPAGE="http://www.ladspa.org/"
SRC_URI="http://www.ladspa.org/download/${MY_P}.tgz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	>=sys-apps/sed-4"

S=${WORKDIR}/${MY_PN}/src

src_unpack() {
	unpack ${A}
	epatch "${FILESDIR}/${P}-fbsd.patch"
	epatch "${FILESDIR}/${P}-darwin.patch"
	sed -i \
		-e "/^CFLAGS/ s:-O3:${CFLAGS}:" \
		"${S}/makefile" || die "sed makefile failed (CFLAGS)"
	sed -i \
		-e 's:-mkdirhier:mkdir\ -p:g' \
		"${S}/makefile" || die "sed makefile failed (mkdirhier)"
	epatch "${FILESDIR}/${P}-test.patch"
	epatch "${FILESDIR}/${P}-gcc4.patch"
}

src_compile() {
	# It sets CXXFLAGS to CFLAGS, can be wrong..
	# Just set CXXFLAGS to what they should be
	emake -j1 targets CXXFLAGS="$CXXFLAGS -I. -fPIC" || die
}

src_test() {
	# needed for sox to allow playback of the test sounds
	addwrite /dev/dsp

	emake test || die
}

src_install() {
	make \
		INSTALL_PLUGINS_DIR="${ED}/usr/$(get_libdir)/ladspa" \
		INSTALL_INCLUDE_DIR="${ED}/usr/include" \
		INSTALL_BINARY_DIR="${ED}/usr/bin" \
		install || die "make install failed"

	cd ../doc && \
		dohtml *.html || die "dohtml failed"

	# Needed for apps like rezound
	dodir /etc/env.d
	echo "LADSPA_PATH=${EPREFIX}/usr/$(get_libdir)/ladspa" > "${ED}/etc/env.d/60ladspa"
}
