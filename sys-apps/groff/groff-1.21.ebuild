# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/groff/groff-1.21.ebuild,v 1.2 2011/01/05 14:38:41 matsuu Exp $

inherit autotools eutils toolchain-funcs

DESCRIPTION="Text formatter used for man pages"
HOMEPAGE="http://www.gnu.org/software/groff/groff.html"
SRC_URI="mirror://gnu/groff/${P}.tar.gz
	linguas_ja? ( mirror://gentoo/${P}-japanese.patch.bz2 )"

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
		epatch "${WORKDIR}"/${P}-japanese.patch #255292 #350534
		eautoconf
		eautoheader
	fi

	# from upstream, #353287, #353377
	epatch "${FILESDIR}"/groff-1.21-makefile.patch
	epatch "${FILESDIR}"/groff-1.21-gnulib.patch
	# make sure we don't get a crappy `g' nameprefix
	epatch "${FILESDIR}"/groff-1.19.2-no-g-nameprefix.patch
	AT_M4DIR=m4 eautoreconf
}

src_compile() {
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

	use examples || rm -rf "${ED}"/usr/share/doc/${PF}/examples
}
