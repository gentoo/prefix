# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/groff/groff-1.20.1-r3.ebuild,v 1.2 2010/07/25 21:29:44 jer Exp $

inherit autotools eutils toolchain-funcs

DESCRIPTION="Text formatter used for man pages"
HOMEPAGE="http://www.gnu.org/software/groff/groff.html"
SRC_URI="mirror://gnu/groff/${P}.tar.gz
	linguas_ja? ( mirror://gentoo/${P}-r2-japanese.patch.bz2 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="examples X linguas_ja"

DEPEND=">=sys-apps/texinfo-4.7-r1
	X? (
		x11-libs/libX11
		x11-libs/libXt
		x11-libs/libXmu
		x11-libs/libXaw
		x11-libs/libSM
		x11-libs/libICE
	)"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/${PN}-1.19.2-man-unicode-dashes.patch #16108 #17580 #121502
	epatch "${FILESDIR}"/${P}-tmac-ec.patch #263524
	epatch "${FILESDIR}"/${P}-Thtml-mem-leak.patch #294045
	epatch "${FILESDIR}"/${P}-double-frees-mem-leaks.patch #294045

	# put the docs in the Gentoo-specific spot
	sed -i \
		-e '/^docdir=/s/=.*/=@docdir@/' \
		Makefile.in \
		|| die "sed failed"

	# Make sure we can cross-compile this puppy
	if tc-is-cross-compiler ; then
		sed -i \
			-e '/^GROFFBIN=/s:=.*:=${EPREFIX}/usr/bin/groff:' \
			-e '/^TROFFBIN=/s:=.*:=${EPREFIX}/usr/bin/troff:' \
			-e '/^GROFF_BIN_PATH=/s:=.*:=:' \
			-e '/^GROFF_BIN_DIR=/s:=.*:=:' \
			contrib/*/Makefile.sub \
			doc/Makefile.in \
			doc/Makefile.sub || die "cross-compile sed failed"
	fi

	cat <<-EOF >> tmac/mdoc.local
	.ds volume-operating-system Gentoo
	.ds operating-system Gentoo/${KERNEL}
	.ds default-operating-system Gentoo/${KERNEL}
	EOF

	if use linguas_ja ; then
		epatch "${WORKDIR}"/${P}-r2-japanese.patch #255292
		eautoconf
		eautoheader
	fi

	# Darwin gcc has a bug? http://www.mail-archive.com/groff@gnu.org/msg04756.html
	if [[ ${CHOST} == *-darwin* ]] ; then
		sed -i -e 's/inline node/node/' src/roff/troff/node.cpp || die
	fi
	# make sure we don't get a crappy `g' nameprefix
	epatch "${FILESDIR}"/groff-1.19.2-no-g-nameprefix.patch
	AT_M4DIR=m4 eautoreconf
}

src_compile() {
	# Fix problems with not finding g++
#	tc-export CC CXX
	econf \
		--with-appresdir="${EPREFIX}"/usr/share/X11/app-defaults \
		--docdir="${EPREFIX}"/usr/share/doc/${PF} \
		$(use_with X x) \
		$(use linguas_ja && echo --enable-japanese)
	emake || die
}

src_install() {
	emake install DESTDIR="${D}" || die

	# The following links are required for man #123674
	dosym eqn /usr/bin/geqn
	dosym tbl /usr/bin/gtbl

	dodoc BUG-REPORT ChangeLog MORE.STUFF NEWS \
		PROBLEMS PROJECTS README REVISION TODO VERSION

	if ! use examples ; then
		rm -rf "${ED}"/usr/share/doc/${PF}/examples
	fi
}
