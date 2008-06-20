# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

ETYPE="gcc-compiler"

inherit eutils toolchain

GCC_VERS=${PV/_p*/}
APPLE_VERS=${PV/*_p/}
DESCRIPTION="Apple branch of the GNU Compiler Collection, iPhone SDK Beta 7"
HOMEPAGE="http://gcc.gnu.org"
SRC_URI="http://www.opensource.apple.com/darwinsource/tarballs/other/gcc-${APPLE_VERS}.tar.gz"
LICENSE="APSL-2 GPL-2"

if is_crosscompile; then
	SLOT="${CTARGET}-40"
else
	SLOT="40"
fi

KEYWORDS="~ppc-macos ~x86-macos"

IUSE="nls objc objc++ nocxx"

RDEPEND=">=sys-libs/zlib-1.1.4
	>=sys-libs/ncurses-5.2-r2
	nls? ( sys-devel/gettext )"
DEPEND="${RDEPEND}
	>=sys-apps/texinfo-4.2-r4
	>=sys-devel/bison-1.875
	>=${CATEGORY}/odcctools-20071104"

S=${WORKDIR}/gcc-${APPLE_VERS}

# TPREFIX is the prefix of the CTARGET installation
export TPREFIX=${TPREFIX:-${EPREFIX}}

if is_crosscompile ; then
	BINPATH=${EPREFIX}/usr/${CHOST}/${CTARGET}/gcc-bin/${GCC_VERS}
else
	BINPATH=${EPREFIX}/usr/${CTARGET}/gcc-bin/${GCC_VERS}
fi

src_unpack() {
	unpack ${A}
	cd "${S}"
	# we use our libtool
	sed -i -e "s:/usr/bin/libtool:${EPREFIX}/usr/bin/${CTARGET}-libtool:" \
		gcc/config/darwin.h || die "sed gcc/config/darwin.h failed"
	# add prefixed Frameworks to default search paths (may want to change this
	# in a cross-compile)
	sed -i -e "/\"\/System\/Library\/Frameworks\"\,/i\ \   \"${EPREFIX}/Frameworks\"\, " \
		gcc/config/darwin-c.c || die "sed  gcc/config/darwin-c.c failed"

	# Workaround deprecated "+Nc" syntax for GNU tail(1)
	sed -i -e "s:tail +16c:tail -c +16:g" \
		gcc/Makefile.in || die "sed gcc/Makefile.in failed."

	epatch "${FILESDIR}"/${PN}-4.0.1_p5465-default-altivec.patch
}

src_compile() {
	local langs="c"
	use nocxx || langs="${langs},c++"
	use objc && langs="${langs},objc"
	use objc++ && langs="${langs/,objc/},objc,obj-c++" # need objc with objc++

	local myconf="${myconf} \
		--prefix=${EPREFIX}/usr \
		--bindir=${BINPATH} \
		--includedir=${EPREFIX}/usr/lib/gcc/${CTARGET}/${GCC_VERS}/include \
		--datadir=${EPREFIX}/usr/share/gcc-data/${CTARGET}/${GCC_VERS} \
		--mandir=${EPREFIX}/usr/share/gcc-data/${CTARGET}/${GCC_VERS}/man \
		--infodir=${EPREFIX}/usr/share/gcc-data/${CTARGET}/${GCC_VERS}/info \
		--libdir=${EPREFIX}/usr/lib/gcc/${CTARGET}/${GCC_VERS} \
		--with-gxx-include-dir=${EPREFIX}/usr/lib/gcc/${CTARGET}/${GCC_VERS}/include/g++-v${GCC_VERS/\.*/} \
		--host=${CHOST}"

	if is_crosscompile ; then
		# Straight from the GCC install doc:
		# "GCC has code to correctly determine the correct value for target
		# for nearly all native systems. Therefore, we highly recommend you
		# not provide a configure target when configuring a native compiler."
		myconf="${myconf} --target=${CTARGET}"

		# Tell compiler where to find what it needs
		myconf="${myconf} --with-sysroot=${EPREFIX}/usr/${CTARGET}"

		# Set this to something sane for both native and target
		CFLAGS="-O2 -pipe"

		local VAR="CFLAGS_"${CTARGET//-/_}
		CXXFLAGS=${!VAR}
	fi
	[[ -n ${CBUILD} ]] && myconf="${myconf} --build=${CBUILD}"

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

	# languages to build
	myconf="${myconf} --enable-languages=${langs}"

	# ???
	myconf="${myconf} --enable-shared --enable-threads=posix"

	# make clear we're in an offset
	use prefix && myconf="${myconf} --with-local-prefix=${TPREFIX}/usr"

	# we don't use a GNU linker, so tell GCC where to find the linker stuff we
	# want it to use
	myconf="${myconf} \
		--with-as=${EPREFIX}/usr/bin/${CTARGET}-as \
		--with-ld=${EPREFIX}/usr/bin/${CTARGET}-ld"

	# make sure we never do multilib stuff, for that we need a different Prefix
	myconf="${myconf} --disable-multilib"

	# The produced libgcc_s.dylib is faulty if using a bit too much
	# optimisation.  Nail it down to something sane
	CFLAGS="-O2 -pipe"
	CXXFLAGS=${CFLAGS}

	# http://gcc.gnu.org/ml/gcc-patches/2006-11/msg00765.html
	# (won't hurt if already 64-bits, but is essential when coming from a
	# multilib compiler -- the default)
	[[ ${CTARGET} == powerpc64-* || ${CTARGET} == x86_64-* ]] && \
		export CC="gcc -m64"

	mkdir -p "${WORKDIR}"/build
	cd "${WORKDIR}"/build
	einfo "Configuring GCC with: ${myconf//--/\n\t--}"
	"${S}"/configure ${myconf} || die "conf failed"
	emake bootstrap || die "emake failed"
}

src_install() {
	cd "${WORKDIR}"/build
	# -jX doesn't work
	emake -j1 DESTDIR="${D}" install || die

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

	# Since we're not multilib, we're either one of both
	[[ ${CTARGET} == powerpc64-* || ${CTARGET} == x86_64-* ]] \
		&& BITS="64" \
		|| BITS="32"
	echo "GCCBITS=\"${BITS}\"" >> ${gcc_envd_file}

	echo "MANPATH=\"${EPREFIX}/usr/share/gcc-data/${CHOST}/${GCC_VERS}/man\"" >> ${gcc_envd_file}
	echo "INFOPATH=\"${EPREFIX}/usr/share/gcc-data/${CHOST}/${GCC_VERS}/info\"" >> ${gcc_envd_file}
	echo "STDCXX_INCDIR=\"g++-v${GCC_VERS/\.*/}\"" >> ${gcc_envd_file}
	is_crosscompile && echo "CTARGET=${CTARGET}" >> ${gcc_envd_file}
}

pkg_postinst() {
	# beware this also switches when it's on another branch version of GCC
	gcc-config ${CTARGET}-${GCC_VERS}
}

pkg_postrm() {
	# clean up the cruft left behind by cross-compilers
	if is_crosscompile ; then
		if [[ -z $(ls "${EROOT}"/etc/env.d/gcc/${CTARGET}* 2>/dev/null) ]] ; then
			rm -f "${EROOT}"/etc/env.d/gcc/config-${CTARGET}
			rm -f "${EROOT}"/etc/env.d/??gcc-${CTARGET}
			rm -f "${EROOT}"/usr/bin/${CTARGET}-{gcc,{g,c}++}{,32,64}
		fi
		return 0
	fi
}
