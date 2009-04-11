# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/slang/slang-2.1.3-r1.ebuild,v 1.20 2008/06/13 05:30:44 vapier Exp $

inherit eutils multilib

DESCRIPTION="a portable programmer's library designed to allow a developer to create robust portable software."
HOMEPAGE="http://www.s-lang.org"
SRC_URI="ftp://ftp.fu-berlin.de/pub/unix/misc/slang/v${PV%.*}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="cjk pcre png readline"

RDEPEND="sys-libs/ncurses
	pcre? ( dev-libs/libpcre )
	png? ( media-libs/libpng )
	cjk? ( dev-libs/oniguruma )
	readline? ( sys-libs/readline )"
DEPEND="${RDEPEND}
	!=sys-libs/slang-2.1.2"

pkg_setup() {
	local fail="Re-emerge sys-libs/ncurses with USE -minimal."
	if built_with_use sys-libs/ncurses minimal; then
		eerror "${fail}"
		die "${fail}"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-2.1.2-slsh-libs.patch
	epatch "${FILESDIR}"/${P}-uclibc.patch
	epatch "${FILESDIR}"/${P}-interix.patch
}

src_compile() {
	local readline

	if use readline; then
		readline=gnu
	else
		readline=slang
	fi

	econf $(use_with cjk onig) $(use_with pcre) $(use_with png) \
		--with-readline=${readline}

	emake -j1 elf static || die "emake elf static failed."

	cd slsh
	emake -j1 slsh || die "emake slsh failed."
}

src_install() {
	emake -j1 DESTDIR="${D}" install-all || die "emake install-all failed."

	rm -rf "${ED}"/usr/share/doc/{slang,slsh}

	dodoc NEWS README *.txt doc/{,internal,text}/*.txt
	dohtml doc/slangdoc.html slsh/doc/html/*.html
}
