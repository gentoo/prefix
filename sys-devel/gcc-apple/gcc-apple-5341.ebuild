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

KEYWORDS="~ppc-macos ~x86-macos"

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
	sed -i -e "s:/usr/bin/libtool:${EPREFIX}/usr/bin/libtool:" \
		gcc/config/darwin.h || die "sed gcc/config/darwin.h failed"
	# add prefixed Frameworks to default search paths
	sed -i -e "/\"\/System\/Library\/Frameworks\"\,/i\ \   \"${EPREFIX}/Frameworks\"\, " \
		gcc/config/darwin-c.c || die "sed  gcc/config/darwin-c.c failed"

	# Workaround deprecated "+Nc" syntax for GNU tail(1)
	sed -i -e "s:tail +16c:tail -c +16:g" \
		gcc/Makefile.in || die "sed gcc/Makefile.in failed."
}
	
src_compile() {
	local myconf=""
	# <grobian@gentoo.org> - 2006-09-19:
	# figure out whether the CPU we're on is 64-bits capable using a
	# simple C program and requesting the compiler to compile it with
	# 64-bits if possible.  Since Apple ships multilib compilers, it
	# will always compile 64-bits code, but might fail running,
	# depending on the CPU, so the resulting program might fail.  Thanks
	# Tobias Hahn for working that out.
	cd "${T}"
	echo '
#include <stdio.h>

int main() {
	printf("%d\n", sizeof(size_t) * 8);
}
' > bits.c
	gcc -m64 -o bits bits.c
	[ "`./bits`" != "64" ] && myconf="--disable-multilib"

	mkdir -p ${WORKDIR}/build
	cd ${WORKDIR}/build
	${S}/configure \
	$(with_prefix) \
	$(with_mandir) \
	$(with_localstatedir) \
	--build=${CHOST} \
	--host=${CHOST} \
	--target=${CHOST} \
	--with-local-prefix=${EPREFIX} \
	--with-as=${EPREFIX}/usr/bin/as \
	--with-ld=${EPREFIX}/usr/bin/ld \
	--enable-languages=c,objc,c++,obj-c++ \
	--with-system-zlib \
	--disable-checking -disable-werror \
	$myconf || die "conf failed"
	make -j1 bootstrap || die "emake failed"
}

src_install() {
	cd ${WORKDIR}/build
	make DESTDIR=${D} install || die

	use build && rm -rf "${ED}"/usr/{man,share}
}
