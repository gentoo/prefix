# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit eutils

GCC_VERS=${PV/_p*/}
APPLE_VERS=${PV/*_p/}
DESCRIPTION="Apple branch of the GNU Compiler Collection, Xcode 2.4"
HOMEPAGE="http://gcc.gnu.org"
SRC_URI="http://www.opensource.apple.com/darwinsource/tarballs/other/gcc-${APPLE_VERS}.tar.gz"

LICENSE="APSL-2 GPL-2"
SLOT="40"

KEYWORDS="~ppc-macos ~x86-macos"

IUSE="nls objc objc++ nocxx"

RDEPEND=">=sys-libs/zlib-1.1.4
	>=sys-libs/ncurses-5.2-r2
	nls? ( sys-devel/gettext )
	>=sys-devel/gcc-config-1.3.12-r4"
DEPEND="${RDEPEND}
	>=sys-apps/texinfo-4.2-r4
	>=sys-devel/bison-1.875
	sys-devel/odcctools"

S=${WORKDIR}/gcc-${APPLE_VERS}

src_unpack() {
	unpack ${A}
	cd "${S}"
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
	local langs="c"
	use nocxx || langs="${langs},c++"
#	use fortran && langs="${langs},f95"
	use objc && langs="${langs},objc"
	use objc++ && langs="${langs/,objc/},objc,obj-c++" # need objc with objc++
#	use gcj && langs="${langs},java"

	local myconf="${myconf} \
		--prefix=${EPREFIX}/usr \
		--bindir=${EPREFIX}/usr/${CHOST}/gcc-bin/${GCC_VERS} \
		--includedir=${EPREFIX}/usr/lib/gcc/${CHOST}/${GCC_VERS}/include \
		--datadir=${EPREFIX}/usr/share/gcc-data/${CHOST}/${GCC_VERS} \
		--mandir=${EPREFIX}/usr/share/gcc-data/${CHOST}/${GCC_VERS}/man \
		--infodir=${EPREFIX}/usr/share/gcc-data/${CHOST}/${GCC_VERS}/info \
		--with-gxx-include-dir=${EPREFIX}/usr/lib/gcc/${CHOST}/${GCC_VERS}/include/g++-v${GCC_VERS/\.*/} \
		--host=${CHOST} \
		--enable-version-specific-runtime-libs"
	[[ -n ${CBUILD} ]] && myconf="${myconf} --build=${CBUILD}"

	# Straight from the GCC install doc:
	# "GCC has code to correctly determine the correct value for target
	# for nearly all native systems. Therefore, we highly recommend you
	# not provide a configure target when configuring a native compiler."

	# Native Language Support
	if use nls ; then
		myconf="${myconf} --enable-nls --without-included-gettext"
	else
		myconf="${myconf} --disable-nls"
	fi

	# reasonably sane globals (hopefully)
	# --disable-libunwind-exceptions needed till unwind sections get fixed. see ps.m for details
	myconf="${myconf} \
		--with-system-zlib \
		--disable-checking \
		--disable-werror \
		--disable-libunwind-exceptions"

	# languages to build
	myconf="${myconf} --enable-languages=${langs}"

	# ???
	myconf="${myconf} --enable-shared --enable-threads=posix"

	# make clear we're in an offset
	if [[ ${EPREFIX%/} != "" ]] ; then
		myconf="${myconf} --with-local-prefix=${EPREFIX}/usr"
	fi

	# we don't use a GNU linker, so tell GCC where to find the linker stuff we
	# want it to use
	myconf="${myconf} \
		--with-as=${EPREFIX}/usr/bin/as \
		--with-ld=${EPREFIX}/usr/bin/ld"

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
	# x86_64 gcc building is broken
	if [[ ${CHOST} != powerpc-*-darwin* ]] && [[ $(./bits) != 64 ]] ; then
		myconf="${myconf} --disable-multilib"
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
	find "${ED}" -name libiberty.a -exec rm -f {} \;

	# create gcc-config entry
	dodir /etc/env.d/gcc
	local gcc_envd_base="/etc/env.d/gcc/${CHOST}-${GCC_VERS}"

	gcc_envd_file="${ED}${gcc_envd_base}"

	echo "PATH=\"${EPREFIX}/usr/${CHOST}/gcc-bin/${GCC_VERS}\"" > ${gcc_envd_file}
	echo "ROOTPATH=\"${EPREFIX}/usr/${CHOST}/gcc-bin/${GCC_VERS}\"" >> ${gcc_envd_file}

	LDPATH="${EPREFIX}/usr/lib/gcc/${CHOST}/${GCC_VERS}"
	echo "LDPATH=\"${LDPATH}\"" >> ${gcc_envd_file}

	BITS=$(${ED}/usr/${CHOST}/gcc-bin/${GCC_VERS}/gcc -dumpspecs | grep -A1 multilib: | tail -n1 | grep -o 64 | head -n1)
	[[ -z ${BITS} ]] \
		&& BITS="32" \
		|| BITS="32 ${BITS}"
	echo "GCCBITS=\"${BITS}\"" >> ${gcc_envd_file}

	echo "MANPATH=\"${EPREFIX}/usr/share/gcc-data/${CHOST}/${GCC_VERS}/man\"" >> ${gcc_envd_file}
	echo "INFOPATH=\"${EPREFIX}/usr/share/gcc-data/${CHOST}/${GCC_VERS}/info\"" >> ${gcc_envd_file}
	echo "STDCXX_INCDIR=\"g++-v${GCC_VERS/\.*/}\"" >> ${gcc_envd_file}
}

pkg_postinst() {
	# beware this also switches when it's on another branch version of GCC
	gcc-config ${CHOST}-${GCC_VERS}
}
