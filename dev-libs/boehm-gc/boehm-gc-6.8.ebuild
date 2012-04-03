# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/boehm-gc/boehm-gc-6.8.ebuild,v 1.11 2011/11/13 18:56:12 vapier Exp $

inherit eutils

MY_P="gc${PV/_/}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="The Boehm-Demers-Weiser conservative garbage collector"
HOMEPAGE="http://www.hpl.hp.com/personal/Hans_Boehm/gc/"
SRC_URI="http://www.hpl.hp.com/personal/Hans_Boehm/gc/gc_source/${MY_P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="cxx threads"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e '/^SUBDIRS/s/doc//' Makefile.in || die
	epatch "${FILESDIR}"/${PN}-6.5-gentoo.patch
	epatch "${FILESDIR}"/gc6.6-builtin-backtrace-uclibc.patch
}

src_compile() {
	econf \
		$(use_enable cxx cplusplus) \
		$(use threads || echo --disable-threads)
	emake || die
}

src_install() {
	make DESTDIR="${D}" install || die

	rm -rf "${ED}"/usr/share/gc || die

	# dist_noinst_HEADERS
	insinto /usr/include/gc
	doins include/{cord.h,ec.h,javaxfc.h}
	insinto /usr/include/gc/private
	doins include/private/*.h

	dodoc README.QUICK doc/README* doc/barrett_diagram
	dohtml doc/*.html
	newman doc/gc.man GC_malloc.1
}
