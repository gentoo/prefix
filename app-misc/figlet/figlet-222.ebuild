# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/figlet/figlet-222.ebuild,v 1.13 2008/03/12 22:05:03 armin76 Exp $

EAPI="prefix"

inherit eutils bash-completion

MY_P=${P/-/}
DESCRIPTION="program for making large letters out of ordinary text"
HOMEPAGE="http://www.figlet.org/"
# Bug 35339 - add more fonts to figlet ebuild
# The fonts are available from the figlet site, but they don't
# have versions so we mirror them ourselves.
SRC_URI="ftp://ftp.figlet.org/pub/figlet/program/unix/${MY_P}.tar.gz
	mirror://gentoo/contributed-${PN}-221.tar.gz
	mirror://gentoo/ms-dos-${PN}-221.tar.gz"

LICENSE="AFL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos"
IUSE=""

DEPEND=""

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"

	cp "${WORKDIR}"/contributed/C64-fonts/*.flf fonts/ || die
	cp "${WORKDIR}"/contributed/bdffonts/*.flf fonts/ || die
	cp "${WORKDIR}"/ms-dos/*.flf fonts/ || die
	cp "${WORKDIR}"/contributed/*.flf fonts/ || die

	epatch "${FILESDIR}"/${P}-gentoo.diff
	sed -i \
		-e "s/CFLAGS = -g/CFLAGS = ${CFLAGS}/g" Makefile \
		|| die "sed failed"
}

src_compile() {
	make clean || die "make clean failed"
	emake \
	    DEFAULTFONTDIR="${EPREFIX}"/usr/share/figlet \
		figlet || die "emake failed"
}

src_install() {
	dodir /usr/bin /usr/share/man/man6 || die "dodir failed"
	chmod +x figlist showfigfonts
	emake \
		DESTDIR="${ED}"/usr/bin \
		MANDIR="${ED}"/usr/share/man/man6 \
	    DEFAULTFONTDIR="${ED}"/usr/share/figlet \
		install || die "make install failed"

	dodoc README figfont.txt
	dobashcompletion "${FILESDIR}"/figlet.bashcomp
}
