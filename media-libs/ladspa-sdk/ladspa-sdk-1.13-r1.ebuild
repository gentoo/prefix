# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/ladspa-sdk/ladspa-sdk-1.13-r1.ebuild,v 1.9 2011/06/07 07:28:15 radhermit Exp $

EAPI=4

inherit eutils toolchain-funcs portability flag-o-matic

MY_PN=${PN/-/_}
MY_P=${MY_PN}_${PV}

DESCRIPTION="The Linux Audio Developer's Simple Plugin API"
HOMEPAGE="http://www.ladspa.org/"
SRC_URI="http://www.ladspa.org/download/${MY_P}.tgz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

RDEPEND=""
DEPEND=">=sys-apps/sed-4"

S="${WORKDIR}/${MY_PN}/src"

src_prepare() {
	epatch "${FILESDIR}"/${P}-properbuild.patch \
		"${FILESDIR}"/${P}-asneeded.patch \
		"${FILESDIR}"/${P}-fbsd.patch \
		"${FILESDIR}"/${P}-no-LD.patch

	epatch "${FILESDIR}/${P}-darwin.patch"
	sed -i -e 's:-sndfile-play*:@echo Disabled \0:' \
		makefile || die "sed makefile failed (sound playing tests)"
}

src_compile() {
	emake CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" \
		DYNAMIC_LD_LIBS="$(dlopen_lib)" \
		CC="$(tc-getCC)" CXX="$(tc-getCXX)" \
		targets
}

src_install() {
	emake INSTALL_PLUGINS_DIR="/usr/$(get_libdir)/ladspa" \
		DESTDIR="${ED}" \
		MKDIR_P="mkdir -p" \
		install

	dohtml ../doc/*.html

	# Needed for apps like rezound
	dodir /etc/env.d
	echo "LADSPA_PATH=${EPREFIX}/usr/$(get_libdir)/ladspa" > "${ED}/etc/env.d/60ladspa"
}
