# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/boehm-gc/boehm-gc-7.2_alpha4.ebuild,v 1.2 2010/09/26 22:13:45 xmw Exp $

inherit eutils

MY_P="gc-${PV/_/}"
S="${WORKDIR}/${MY_P}"

DESCRIPTION="The Boehm-Demers-Weiser conservative garbage collector"
HOMEPAGE="http://www.hpl.hp.com/personal/Hans_Boehm/gc/"
SRC_URI="http://www.hpl.hp.com/personal/Hans_Boehm/gc/gc_source/${MY_P}.tar.gz"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="nocxx threads"

DEPEND="dev-libs/libatomic_ops"
RDEPEND="${DEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-7.2-darwin.patch
}

src_compile() {
	local myconf="--with-libatomic-ops=yes"

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
	emake DESTDIR="${D}" install || die

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
