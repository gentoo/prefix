# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/ispell/ispell-3.3.02.ebuild,v 1.2 2007/11/22 19:25:48 philantrop Exp $

EAPI="prefix"

inherit eutils multilib

PATCH_VER="0.2"
DESCRIPTION="fast screen-oriented spelling checker"
HOMEPAGE="http://fmg-www.cs.ucla.edu/geoff/ispell.html"
SRC_URI="http://fmg-www.cs.ucla.edu/geoff/tars/${P}.tar.gz
		mirror://gentoo/${P}-gentoo-${PATCH_VER}.diff.bz2"

SLOT="0"
LICENSE="as-is"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE=""

DEPEND="sys-apps/miscfiles
		>=sys-libs/ncurses-5.2"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${WORKDIR}/${P}-gentoo-${PATCH_VER}.diff"

	sed -i -e "s:GENTOO_LIBDIR:$(get_libdir):" local.h.gentoo || die "setting libdir failed"
	cp local.h.gentoo local.h
}

src_compile() {
	emake -j1 config.sh || die "configuration failed"

	# Fix config.sh to install to ${ED}
	cp -p config.sh config.sh.orig
	sed \
		-e "s:^\(BINDIR='\)\(.*\):\1${ED}\2:" \
		-e "s:^\(LIBDIR='\)\(.*\):\1${ED}\2:" \
		-e "s:^\(MAN1DIR='\)\(.*\):\1${ED}\2:" \
		-e "s:^\(MAN45DIR='\)\(.*\):\1${ED}\2:" \
		< config.sh > config.sh.install

	emake -j1 || die "compilation failed"
}

src_install() {
	cp -p  config.sh.install config.sh

	# Need to create the directories to install into
	# before 'make install'. Build environment **doesn't**
	# check for existence and create if not already there.
	dodir /usr/bin /usr/$(get_libdir)/ispell /usr/share/info \
		/usr/share/man/man1 /usr/share/man/man5

	emake -j1 install || die "Installation Failed"

	rmdir "${ED}"/usr/share/info || die "removing empty info dir failed"
	dodoc CHANGES Contributors README WISHES || die "installing docs failed"
	dosed "s:${D}::g" "${ED}"/usr/share/man/man1/ispell.1 || die "dosed failed"
}

pkg_postinst() {
	echo
	ewarn "If you just updated from an older version of ${PN} you *have* to re-emerge"
	ewarn "all your dictionaries to avoid segmentation faults and other problems."
	echo
}
