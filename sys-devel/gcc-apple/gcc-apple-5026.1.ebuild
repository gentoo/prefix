# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit eutils

DESCRIPTION="Apple branch of the GNU Compiler Collection"
HOMEPAGE="http://gcc.gnu.org"
SRC_URI="http://darwinsource.opendarwin.org/tarballs/other/gcc-${PV}.tar.gz"

LICENSE="APSL-2 GPL-2"
SLOT="0"

KEYWORDS="~ppc-macos"

IUSE=""

RDEPEND="virtual/libc
	>=sys-libs/zlib-1.1.4
	!build? (
		>=sys-libs/ncurses-5.2-r2
		nls? ( sys-devel/gettext )
	)"
DEPEND="${RDEPEND}
	>=sys-apps/texinfo-4.2-r4
	>=sys-devel/bison-1.875
	>=sys-devel/odcctools"

S=${WORKDIR}/gcc-${PV}

src_unpack() {
	unpack ${A}
	cd ${S}
	# we use our libtool
	sed -i -e "s:/usr/bin/libtool:${PREFIX}usr/bin/libtool:" \
		gcc/config/darwin.h || die "sed gcc/config/darwin.h failed"
	# add prefixed Frameworks to default search paths
	sed -i -e "/\"\/System\/Library\/Frameworks\"\,/i\ \   \"${PREFIX}Frameworks\"\, " \
		gcc/config/darwin-c.c || die "sed  gcc/config/darwin-c.c failed"
}
	
src_compile() {
	mkdir -p ${WORKDIR}/build
	cd ${WORKDIR}/build
	${S}/configure \
	$(with_prefix) \
	$(with_mandir) \
	$(with_localstatedir) \
	--build=${CHOST} \
	--host=${CHOST} \
	--target=${CHOST} \
	--with-local-prefix=${PREFIX} \
	--with-as=${PREFIX}/usr/bin/as \
	--with-ld=${PREFIX}/usr/bin/ld \
	--enable-languages=c,objc,c++,obj-c++ \
	--with-system-zlib || die "conf failed"
	emake -j2 bootstrap || die "emake failed"
}

src_install() {
	cd ${WORKDIR}/build
	make DESTDIR=${DEST} install || die

	use build && rm -rf "${D}"/usr/{man,share}
}
