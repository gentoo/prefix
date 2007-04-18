# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-arch/cpio/cpio-2.6-r5.ebuild,v 1.14 2007/02/28 21:52:29 genstef Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="A file archival tool which can also read and write tar files"
HOMEPAGE="http://www.gnu.org/software/cpio/cpio.html"
SRC_URI="mirror://gnu/cpio/${P}.tar.bz2"

LICENSE="GPL-2 LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="nls"

DEPEND=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PV}-rili-big-files.patch #68520
	epatch "${FILESDIR}"/${PV}-isnumber.patch #74929
	epatch "${FILESDIR}"/${PV}-umask.patch #79844
	epatch "${FILESDIR}"/${PV}-lstat.patch #80246
	epatch "${FILESDIR}"/${P}-chmodRaceC.patch #90619
	epatch "${FILESDIR}"/${P}-gcc4-tests.patch #89123
	epatch "${FILESDIR}"/${P}-dirTraversal.patch #90619
	epatch "${FILESDIR}"/${P}-checksum.patch
	epatch "${FILESDIR}"/${P}-warnings.patch
	epatch "${FILESDIR}"/${P}-writeOutHeaderBufferOverflow.patch #112140
	epatch "${FILESDIR}"/${P}-stpcpy-hack.patch #123237
}

src_compile() {
	# The configure script has a useless check for gethostname in 
	# libnsl ... but cpio doesn't utilize the lib/func anywhere, 
	# so let's force the lib to not be detected
	ac_cv_lib_nsl_gethostname=no \
	econf \
		$(use_enable nls) \
		--with-bindir="${EPREFIX}"/bin \
		--with-rmt="${EPREFIX}"/usr/sbin/rmt \
		|| die
	emake || die
}

src_install() {
	make install DESTDIR="${D}" || die
	dodoc ChangeLog NEWS README INSTALL
	rm -f "${ED}"/usr/share/man/man1/mt.1
	rmdir "${ED}"/usr/libexec || die
}
