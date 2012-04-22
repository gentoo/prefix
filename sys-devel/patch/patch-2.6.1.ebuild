# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/patch/patch-2.6.1.ebuild,v 1.11 2012/01/25 18:25:49 ssuominen Exp $

inherit flag-o-matic eutils

DESCRIPTION="Utility to apply diffs to files"
HOMEPAGE="http://www.gnu.org/software/patch/patch.html"
SRC_URI="mirror://gnu/patch/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="static test"

RDEPEND=""
DEPEND="${RDEPEND}
	test? ( sys-apps/ed )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	# this file is missing from the tarball bug #300845
	cp "${FILESDIR}"/gnulib_strnlen.c gl/lib/strnlen.c || die
	# from upstream for IRIX, bug #301005
	epatch "${FILESDIR}"/${P}-continue-91e027ab1af51717f9229d07901158e7466fcd6f.patch
	epatch "${FILESDIR}"/${P}-strlen-strdup-f376c5db4a4b169176996c67c8c5ac53c3b18a44.patch

	epatch "${FILESDIR}"/${P}-interix-nomultibyte.patch
	epatch "${FILESDIR}"/${P}-mint.patch # applies on top of interix patch
}

src_compile() {
	use static && append-ldflags -static

	local myconf=""
	[[ ${USERLAND} == "BSD" ]] && use !prefix && myconf="--program-prefix=g"
	econf ${myconf}

	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README
}
