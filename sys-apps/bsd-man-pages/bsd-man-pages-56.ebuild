# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit eutils

DESCRIPTION="A collection of BSD man pages"
HOMEPAGE="www.opensource.apple.com"
SRC_URI="http://www.opensource.apple.com/darwinsource/tarballs/other/bsdmanpages-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~ppc-macos ~x86-macos"
IUSE=""

RDEPEND="virtual/man"

S=${WORKDIR}/bsdmanpages-${PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e "s/root.wheel/${PORTAGE_UID}:${PORTAGE_GID}/g" Makefile
}

src_compile() { :; }

src_install() {
	make install DSTROOT="${D}${EPREFIX}" || die
	dodoc ManPageTemplate.man
}

pkg_postinst() {
	einfo "If you don't have a makewhatis cronjob, then you"
	einfo "should update the whatis database yourself:"
	einfo " # makewhatis -u"
}
