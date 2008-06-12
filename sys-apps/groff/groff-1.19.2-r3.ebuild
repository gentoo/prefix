# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/groff/groff-1.19.2-r3.ebuild,v 1.1 2008/05/05 20:51:26 ulm Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs multilib autotools

DESCRIPTION="Text formatter used for man pages"
HOMEPAGE="http://www.gnu.org/software/groff/groff.html"
SRC_URI="mirror://gnu/groff/${P}.tar.gz
	cjk? ( mirror://gentoo/groff-1.19.2-japanese.patch.bz2 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="cjk X"

DEPEND=">=sys-apps/texinfo-4.7-r1"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# Fix the info pages to have .info extensions,
	# else they do not get gzipped.
	epatch "${FILESDIR}"/${P}-infoext.patch

	epatch "${FILESDIR}"/${P}-man-unicode-dashes.patch #16108 #17580 #121502
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
		--with-appresdir="${EPREFIX}"/usr/share/X11/app-defaults \
		$(use_with X x) \
		$(use_enable cjk japanese) \
		|| die
	emake -j1 || die #Apparently needed on amd64-linux in prefix.
					# (12 Jun 2008, darkside)
}

src_install() {
	dodir /usr/bin
	make \
		prefix="${ED}"/usr \
		bindir="${ED}"/usr/bin \
		libdir="${ED}"/usr/$(get_libdir) \
		appresdir="${ED}"/usr/share/X11/app-defaults \
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
