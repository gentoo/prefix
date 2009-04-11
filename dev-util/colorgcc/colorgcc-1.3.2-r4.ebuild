# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/colorgcc/colorgcc-1.3.2-r4.ebuild,v 1.15 2008/04/13 19:58:55 grobian Exp $

IUSE=""

inherit eutils

DESCRIPTION="Adds color to gcc output"
HOMEPAGE="http://www.mindspring.com/~jamoyers/software/"
SRC_URI="http://www.mindspring.com/~jamoyers/software/colorgcc/${P}.tar.gz"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"

DEPEND="dev-lang/perl"

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/${P}-gentoo-one.patch
	epatch ${FILESDIR}/${P}-gentoo-two.patch
}

src_compile() {
	echo ">>> Nothing to compile"
}

src_install() {
	exeinto /usr/bin
	doexe colorgcc
	dodir /etc/colorgcc /usr/lib/colorgcc/bin
	insinto /etc/colorgcc
	doins colorgccrc
	einfo "Scanning for compiler front-ends"
	into /usr/lib/colorgcc/bin
	for a in gcc cc c++ g++ ${CHOST}-gcc ${CHOST}-c++ ${CHOST}-g++ ; do
		if [ -n "$(type -p ${a})" ]; then
			dosym /usr/bin/colorgcc /usr/lib/colorgcc/bin/${a}
		fi
	done

	dodoc COPYING CREDITS ChangeLog INSTALL
}

pkg_postinst() {
	echo
	elog "If you have existing \$HOME/.colorgccrc files that set the location"
	elog "of the compilers, you should remove those lines for maximum"
	elog "flexibility.  The colorgcc script now knows how to pass the command"
	elog "on to the next step in the PATH without manual tweaking, making it"
	elog "easier to use with things like ccache and distcc on a conditional"
	elog "basis.  You can tweak the /etc/colorgcc/colorgccrc file to change"
	elog "the default settings for everyone (or copy this file as a basis for"
	elog "a custom \$HOME/.colorgccrc file)."
	elog
	elog "NOTE: the symlinks for colorgcc are now located in"
	elog "/usr/lib/colorgcc/bin *NOT* /usr/bin/wrappers.  You'll need to"
	elog "change any PATH settings that referred to the old location."
	echo
	# portage won't delete the old symlinks for users that are upgrading
	# because the old symlinks still point to /usr/bin/colorgcc which exists...
	[ -d ${EROOT}/usr/bin/wrappers ] && rm -fr ${EROOT}/usr/bin/wrappers
}
