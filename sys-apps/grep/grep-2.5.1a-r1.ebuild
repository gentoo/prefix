# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/grep/grep-2.5.1a-r1.ebuild,v 1.9 2009/04/09 16:09:35 loki_val Exp $

inherit flag-o-matic eutils

DESCRIPTION="GNU regular expression matcher"
HOMEPAGE="http://www.gnu.org/software/grep/grep.html"
SRC_URI="mirror://gnu/${PN}/${P}.tar.bz2
	mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls pcre static"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	pcre? ( <=dev-libs/libpcre-7.8 )
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
	epatch "${FILESDIR}"/${P}-getopt-nls.patch
	epatch "${FILESDIR}"/${PN}-2.5.1a-mint.patch

	# retarded
	sed -i 's:__mempcpy:mempcpy:g' lib/*.c || die
}

src_compile() {
	use static && append-ldflags -static

	econf \
		--bindir="${EPREFIX}"/bin \
		$(use_enable nls) \
		$(use_enable pcre perl-regexp) \
		|| die "econf failed"

	use static || [[ ${CHOST} == *-darwin* ]] || sed -i 's:-lpcre:-lpcre -Wl,-Bdynamic:g' src/Makefile

	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed"

	# Override the default shell scripts... grep knows how to act
	# based on how it's called
	ln -sfn grep "${ED}"/bin/egrep || die "ln egrep failed"
	ln -sfn grep "${ED}"/bin/fgrep || die "ln fgrep failed"

	rm -f "${ED}"/usr/lib/charset.alias

	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
}
