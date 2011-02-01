# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/slang/slang-2.2.3.ebuild,v 1.1 2010/12/27 12:51:44 ssuominen Exp $

EAPI=2
inherit eutils

DESCRIPTION="A multi-platform programmer's library designed to allow a developer to create robust software"
HOMEPAGE="http://www.jedsoft.org/slang/"
SRC_URI="mirror://slang/v${PV%.*}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x86-solaris"
IUSE="cjk pcre png readline zlib"

# ncurses for ncurses5-config to get terminfo directory
RDEPEND="sys-libs/ncurses
	pcre? ( dev-libs/libpcre )
	png? ( >=media-libs/libpng-1.4 )
	cjk? ( dev-libs/oniguruma )
	readline? ( sys-libs/readline )
	zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}"

MAKEOPTS="${MAKEOPTS} -j1"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.2.3-slsh-libs.patch
	#epatch "${FILESDIR}"/${PN}-2.1.3-interix.patch

	# avoid linking to -ltermcap race with some systems
	sed -i -e '/^TERMCAP=/s:=.*:=:' configure || die
}

src_configure() {
	local myconf=slang
	use readline && myconf=gnu

	econf \
		--with-readline=${myconf} \
		$(use_with pcre) \
		$(use_with cjk onig) \
		$(use_with png) \
		$(use_with zlib z)
}

src_compile() {
	emake elf static || die

	cd slsh
	emake slsh || die
}

src_install() {
	emake -j1 DESTDIR="${D}" install-all || die "emake install-all failed."

	rm -rf "${ED}"/usr/share/doc/{slang,slsh}

	dodoc NEWS README *.txt doc/{,internal,text}/*.txt
	dohtml doc/slangdoc.html slsh/doc/html/*.html
}
