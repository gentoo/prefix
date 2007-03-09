# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/groff/groff-1.19.2-r1.ebuild,v 1.18 2006/12/30 13:55:47 vapier Exp $

EAPI="prefix"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"
inherit eutils flag-o-matic toolchain-funcs multilib autotools

MB_PATCH="groff_1.18.1-7" #"${P/-/_}-7"
DESCRIPTION="Text formatter used for man pages"
HOMEPAGE="http://www.gnu.org/software/groff/groff.html"
SRC_URI="mirror://gnu/groff/${P}.tar.gz
	cjk? ( mirror://gentoo/groff-1.19.2-japanese.patch.bz2 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="cjk X"

DEPEND=">=sys-apps/texinfo-4.7-r1"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix the info pages to have .info extensions,
	# else they do not get gzipped.
	epatch "${FILESDIR}"/${P}-infoext.patch

	# Make dashes the same as minus on the keyboard so that you
	# can search for it. Fixes #17580 and #16108
	# Thanks to James Cloos <cloos@jhcloos.com>
	epatch "${FILESDIR}"/${PN}-man-UTF-8.diff

	# Fix make dependencies so we can build in parallel
	epatch "${FILESDIR}"/${P}-parallel-make.patch

	# Make sure we can cross-compile this puppy
	if tc-is-cross-compiler ; then
		sed -i \
			-e '/^GROFFBIN=/s:=.*:=${EPREFIX}/usr/bin/groff:' \
			-e '/^TROFFBIN=/s:=.*:=${EPREFIX}/usr/bin/troff:' \
			-e '/^GROFF_BIN_PATH=/s:=.*:=:' \
			contrib/mom/Makefile.sub \
			doc/Makefile.in \
			doc/Makefile.sub || die "cross-compile sed failed"
	fi

	if use cjk ; then
		epatch "${WORKDIR}"/groff-1.19.2-japanese.patch #134377
#		eautoreconf
	fi

	# make sure we don't get a crappy `g' nameprefix
	epatch "${FILESDIR}"/groff-1.19.2-no-g-nameprefix.patch
	eautoreconf
}

src_compile() {
	# Fix problems with not finding g++
	tc-export CC CXX

	# -Os causes segfaults, -O is probably a fine replacement
	# (fixes bug 36008, 06 Jan 2004 agriffis)
	replace-flags -Os -O

	econf \
		--with-appresdir="${EPREFIX}"/etc/X11/app-defaults \
		$(use_with X x) \
		$(use_enable cjk japanese) \
		|| die
	emake || die
}

src_install() {
	dodir /usr/bin
	make \
		prefix="${ED}"/usr \
		bindir="${ED}"/usr/bin \
		libdir="${ED}"/usr/$(get_libdir) \
		appresdir="${ED}"/etc/X11/app-defaults \
		datadir="${ED}"/usr/share \
		mandir="${ED}"/usr/share/man \
		infodir="${ED}"/usr/share/info \
		docdir="${ED}"/usr/share/doc/${PF} \
		install || die

	# The following links are required for man #123674
	dosym eqn /usr/bin/geqn
	dosym tbl /usr/bin/gtbl

	dodoc BUG-REPORT ChangeLog FDL MORE.STUFF NEWS \
		PROBLEMS PROJECTS README REVISION TODO VERSION
}
