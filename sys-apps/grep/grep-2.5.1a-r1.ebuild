# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/grep/grep-2.5.1a-r1.ebuild,v 1.3 2006/10/17 11:24:47 uberlord Exp $

EAPI="prefix"

inherit flag-o-matic eutils

DESCRIPTION="GNU regular expression matcher"
HOMEPAGE="http://www.gnu.org/software/grep/grep.html"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2
	mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="nls pcre static"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	pcre? ( dev-libs/libpcre )
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# work around a weird sparc32 compiler bug
	echo "" >> src/dfa.h

	epatch "${FILESDIR}"/${PN}-2.5.1-manpage.patch
	epatch "${FILESDIR}"/${PN}-2.5.1-fgrep.patch
	epatch "${FILESDIR}"/${PN}-2.5.1-color.patch
	epatch "${FILESDIR}"/${PN}-2.5.1-bracket.patch
	epatch "${FILESDIR}"/${PN}-2.5.1-i18n.patch
	epatch "${FILESDIR}"/${PN}-2.5.1-oi.patch
	epatch "${FILESDIR}"/${PN}-2.5.1-restrict_arr.patch
	epatch "${FILESDIR}"/2.5.1-utf8-case.patch
	epatch "${FILESDIR}"/${PN}-2.5.1-perl-segv.patch #95495
	epatch "${FILESDIR}"/${PN}-2.5.1-fix-devices-skip.patch #113640
	epatch "${FILESDIR}"/${P}-nls.patch

	# retarded
	sed -i 's:__mempcpy:mempcpy:g' lib/*.c || die
}

src_compile() {
	use static && append-ldflags -static

	econf \
		$(with_bindir) \
		$(use_enable nls) \
		$(use_enable pcre perl-regexp) \
		|| die "econf failed"

	use static || sed -i 's:-lpcre:-Wl,-Bstatic -lpcre -Wl,-Bdynamic:g' src/Makefile

	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${EDEST}" install || die "make install failed"

	# Override the default shell scripts... grep knows how to act
	# based on how it's called
	ln -sfn grep "${D}"/bin/egrep || die "ln egrep failed"
	ln -sfn grep "${D}"/bin/fgrep || die "ln fgrep failed"

	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
}
