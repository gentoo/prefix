# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/pth/pth-2.0.7-r3.ebuild,v 1.7 2012/05/09 15:21:08 aballier Exp $

EAPI=4

inherit eutils fixheadtails libtool flag-o-matic autotools

DESCRIPTION="GNU Portable Threads"
HOMEPAGE="http://www.gnu.org/software/pth/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x64-freebsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="debug static-libs"

DEPEND=""
RDEPEND="${DEPEND}"

DOCS="ANNOUNCE AUTHORS ChangeLog NEWS README THANKS USERS"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.0.5-parallelfix.patch
	epatch "${FILESDIR}"/${PN}-2.0.6-ldflags.patch
	epatch "${FILESDIR}"/${PN}-2.0.6-sigstack.patch
	epatch "${FILESDIR}"/${PN}-2.0.7-parallel-install.patch
	epatch "${FILESDIR}"/${PN}-2.0.7-ia64.patch
	epatch "${FILESDIR}"/${PN}-2.0.7-mint.patch

	ht_fix_file aclocal.m4 configure

	eautoconf
	elibtoolize
}

src_configure() {
	# bug 350815
	( use arm || use sh ) && append-flags -U_FORTIFY_SOURCE

	local conf

	[[ ${CHOST} == *-mint* ]] && conf="${conf} --enable-pthread"
	# http://www.mail-archive.com/pth-users@gnu.org/msg00525.html
	[[ ${CHOST} == powerpc*-darwin9 ]] && \
		conf="${conf} --with-mctx-mth=sjlj --with-mctx-dsp=ssjlj --with-mctx-stk=sas"

	use debug && conf="${conf} --enable-debug"	# have a bug --disable-debug and shared

	econf \
		${conf} \
		$(use_enable static-libs static)
}

src_install() {
	default
	find "${ED}" -name '*.la' -exec rm -f {} +
}
