# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/jasspa-microemacs/jasspa-microemacs-20060909.ebuild,v 1.1 2006/12/06 18:22:51 opfer Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Jasspa Microemacs"
HOMEPAGE="http://www.jasspa.com/"
SRC_URI="http://www.jasspa.com/release_${PV}/jasspa-memacros-${PV}-2.tar.gz
	http://www.jasspa.com/release_${PV}/jasspa-mehtml-${PV}.tar.gz
	http://www.jasspa.com/release_${PV}/jasspa-mesrc-${PV}-2.tar.gz
	http://www.jasspa.com/release_${PV}/meicons-extra.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="X"

DEPEND="virtual/libc
	sys-libs/ncurses
	X? ( || ( ( x11-libs/libX11
			x11-libs/libXt
		)
		  virtual/x11 )
	)"

S="${WORKDIR}/me${PV:2}/src"

src_unpack() {
	unpack jasspa-mesrc-${PV}-2.tar.gz
	cd ${T}
	# everything except jasspa-mesrc
	unpack ${A/jasspa-mesrc-${PV}-2.tar.gz/}
	cd ${S}
	epatch "${FILESDIR}/20050505-ncurses.patch"
}

src_compile() {
	# respect CFLAGS
	sed -i "/^COPTIMISE/s/.*/COPTIMISE = ${CFLAGS}/" linux{2,26}.gmk
	local loadpath="~/.jasspa:${EPREFIX}/usr/share/jasspa/site:${EPREFIX}/usr/share/jasspa"
	if use X
	then
		./build -p "$loadpath"
	else
		./build -t c -p "$loadpath"
	fi
}

src_install() {
	dodir /usr/share/jasspa
	keepdir /usr/share/jasspa/site
	if use X; then
		newbin me me32 || die
		dobin me || die
	else
		dobin mec || die
		dosym /usr/bin/mec /usr/bin/me
	fi
	dodoc ../*.txt ../change.log
	cp -r ${T}/* ${ED}/usr/share/jasspa

	insinto /usr/share/applications
	doins ${FILESDIR}/jasspa-microemacs.desktop
}
