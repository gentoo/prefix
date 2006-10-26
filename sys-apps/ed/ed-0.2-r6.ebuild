# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/ed/ed-0.2-r6.ebuild,v 1.4 2006/10/17 11:03:43 uberlord Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="Your basic line editor"
HOMEPAGE="http://www.gnu.org/software/ed/"
SRC_URI="ftp://ftp.gnu.org/pub/gnu/ed/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""

DEPEND="sys-apps/texinfo"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PV}-info-dir.patch
	epatch "${FILESDIR}"/${PV}-mkstemp.patch
	epatch "${FILESDIR}"/${P}-configure-LANG.patch #126041

	# This little autoconf line isn't critical.
	# It's only needed when you want to cross-compile.
	if tc-is-cross-compiler ; then
		chmod 755 configure #73575
		WANT_AUTOCONF=2.1 autoconf || die "autoconf failed"
	fi
}

src_compile() {
	tc-export CC RANLIB
	# very old configure script ... econf wont work
	local myconf="--prefix=${EPREFIX}/ --host=${CHOST}"
	[[ -n ${CBUILD} ]] && myconf="${myconf} --build=${CBUILD}"
	[[ -n ${CTARGET} ]] && myconf="${myconf} --target=${CTARGET}"
	myconf="${myconf} ${EXTRA_ECONF}"
	echo "./configure ${myconf}"
	./configure ${myconf} || die
	emake AR="$(tc-getAR)" || die
}

src_install() {
	chmod 0644 "${S}"/ed.info
	make \
		prefix="${ED}"/ \
		mandir="${ED}"/usr/share/man/man1 \
		infodir="${ED}"/usr/share/info \
		install || die
	dodoc ChangeLog NEWS POSIX README THANKS TODO
}
