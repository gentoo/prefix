# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/boehm-gc/boehm-gc-6.8.ebuild,v 1.1 2006/09/08 17:15:14 matsuu Exp $

EAPI="prefix"

inherit eutils

MY_P="gc${PV/_/}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="The Boehm-Demers-Weiser conservative garbage collector"
HOMEPAGE="http://www.hpl.hp.com/personal/Hans_Boehm/gc/"
SRC_URI="http://www.hpl.hp.com/personal/Hans_Boehm/gc/gc_source/${MY_P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="nocxx threads"

RDEPEND="virtual/libc"

DEPEND="${RDEPEND}
	>=sys-apps/sed-4"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e '/^SUBDIRS/s/doc//' Makefile.in || die
	epatch "${FILESDIR}"/${PN}-6.5-gentoo.patch
	epatch "${FILESDIR}"/gc6.6-builtin-backtrace-uclibc.patch
}

src_compile() {
	local myconf=""

	if use nocxx ; then
		myconf="${myconf} --disable-cplusplus"
	else
		myconf="${myconf} --enable-cplusplus"
	fi

	use threads || myconf="${myconf} --disable-threads"

	econf ${myconf} || die "Configure failed..."
	emake || die
}

src_install() {
	make DESTDIR="${D}" install || die

	# dist_noinst_HEADERS
	insinto /usr/include/gc
	doins include/{cord.h,ec.h,javaxfc.h}
	insinto /usr/include/gc/private
	doins include/private/*.h

	dodoc README.QUICK doc/README* doc/barrett_diagram
	dohtml doc/*.html
	newman doc/gc.man GC_malloc.1
}
