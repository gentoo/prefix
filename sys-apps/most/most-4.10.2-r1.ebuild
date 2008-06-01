# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/most/most-4.10.2-r1.ebuild,v 1.12 2008/02/10 11:33:52 drac Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="An extremely excellent text file reader"
HOMEPAGE="http://freshmeat.net/projects/most/"
SRC_URI="ftp://space.mit.edu/pub/davis/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
IUSE=""

# Note to arch maintainers: you'll need to add to src_install() for your
# arch, since the app's Makefile does strange things with different
# directories for each arch. -- ciaranm, 27 June 2004
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"

DEPEND=">=sys-libs/slang-1.4
	>=sys-libs/ncurses-5.2-r2"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-fix-goto-line.diff
}

src_install() {
	# Changing this to use src/${ARCH}objs/most probably isn't a good
	# idea...
	local objsdir
	case $(tc-arch) in
		x86)
			objsdir=x86objs
		;;
		amd64)
			objsdir=amd64objs
		;;
		sparc)
			objsdir=sparcobjs
		;;
		mips)
			objsdir=mipsobjs
		;;
		ppc)
			objsdir=ppcobjs
		;;
		ppc-macos)
			objsdir=ppcobjs
		;;
		alpha)
			objsdir=alphaobjs
		;;
	esac
	dobin src/${objsdir:-objs}/most || die "Couldn't install binary"

	doman most.1

	dodoc README changes.txt
	docinto txt
	dodoc most.rc lesskeys.rc most-fun.txt
}

pkg_postinst() {
	echo
	einfo "See most.rc in /usr/share/doc/${PF}/txt"
	einfo "for an example /etc/most.conf."
	echo
}
