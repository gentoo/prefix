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

IUSE="nls"

RDEPEND="virtual/libc
	>=sys-libs/zlib-1.1.4
	>=sys-libs/ncurses-5.2-r2
	nls? ( sys-devel/gettext )
	>=sys-devel/gcc-config-1.3.12-r4"
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
	BITS="`./bits`"
	[[ $BITS != 64 ]] && myconf="--disable-multilib"

	# This isn't a parameter; it's the version of the compiler that we're
	# about to build.  It's included in the names of various files and
	# directories in the installed image.
	VERS=`sed -n -e '/version_string/s/.*\"\([^ \"]*\)[ \"].*/\1/p' \
		< ${S}/gcc/version.c || exit 1`

	myconf="${myconf} \
		--build=${CHOST} \
		--host=${CHOST} \
		--target=${CHOST} \
		--prefix=${EPREFIX}/usr \
		--bindir=${EPREFIX}/usr/${CHOST}/gcc-bin/${VERS} \
		--includedir=${EPREFIX}/usr/lib/gcc/${CHOST}/${VERS}/include \
		--datadir=${EPREFIX}/usr/share/gcc-data/${CHOST}/${VERS} \
		--mandir=${EPREFIX}/usr/share/gcc-data/${CHOST}/${VERS}/man \
		--infodir=${EPREFIX}/usr/share/gcc-data/${CHOST}/${VERS}/info \
		--with-gxx-include-dir=${EPREFIX}/usr/lib/gcc/${CHOST}/${VERS}/include/g++-v${VERS/\.*/} \
		--with-as=${EPREFIX}/usr/bin/as \
		--with-ld=${EPREFIX}/usr/bin/ld \
		--enable-languages=c,objc,c++,obj-c++ \
		--with-slibdir=${EPREFIX}/usr/lib"

	# Native Language Support
	if use nls ; then
		myconf="${myconf} --enable-nls --without-included-gettext"
	else
		myconf="${myconf} --disable-nls"
	fi

	# reasonably sane globals (hopefully)
	myconf="${myconf} \
		--with-system-zlib \
		--disable-checking \
		--disable-werror"

	if [[ ${EPREFIX%/} != "" ]] ; then
		myconf="${myconf} --with-local-prefix=${EPREFIX}"
	fi

	mkdir -p ${WORKDIR}/build
	cd ${WORKDIR}/build
	einfo "Configuring GCC with: ${myconf//--/\n\t--}"
	${S}/configure ${myconf} || die "conf failed"
	make -j1 bootstrap || die "emake failed"
}

src_install() {
	cd ${WORKDIR}/build
	make DESTDIR="${D}" install || die

	use build && rm -rf "${ED}"/usr/{man,share}

	VERS=`sed -n -e '/version_string/s/.*\"\([^ \"]*\)[ \"].*/\1/p' \
		< ${S}/gcc/version.c || exit 1`

	# create gcc-config entry
	dodir /etc/env.d/gcc
	local gcc_envd_base="/etc/env.d/gcc/${CHOST}-${VERS}"

	gcc_envd_file="${ED}${gcc_envd_base}"

	echo "PATH=\"${EPREFIX}/usr/${CHOST}/gcc-bin/${VERS}\"" > ${gcc_envd_file}
	echo "ROOTPATH=\"${EPREFIX}/usr/${CHOST}/gcc-bin/${VERS}\"" >> ${gcc_envd_file}

	LDPATH="${EPREFIX}/usr/lib/gcc/${CHOST}/${VERS}"
	echo "LDPATH=\"${LDPATH}\"" >> ${gcc_envd_file}

	[[ ${BITS} == 64 ]] && BITS="32 ${BITS}"
	echo "GCCBITS=\"${BITS}\"" >> ${gcc_envd_file}

	echo "MANPATH=\"${EPREFIX}/usr/share/gcc-data/${CHOST}/${VERS}/man\"" >> ${gcc_envd_file}
	echo "INFOPATH=\"${EPREFIX}/usr/share/gcc-data/${CHOST}/${VERS}/info\"" >> ${gcc_envd_file}
	echo "STDCXX_INCDIR=\"g++-v${VERS/\.*/}\"" >> ${gcc_envd_file}
}

pkg_postinst() {
	# beware, should match $VERS
	gcc-config ${CHOST}-4.0.1
}
