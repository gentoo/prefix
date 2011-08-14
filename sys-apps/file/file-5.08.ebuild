# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/file/file-5.08.ebuild,v 1.2 2011/08/04 10:54:29 ssuominen Exp $

EAPI="2"
PYTHON_DEPEND="python? *"
SUPPORT_PYTHON_ABIS="1"
RESTRICT_PYTHON_ABIS="*-jython"

inherit eutils distutils autotools flag-o-matic

DESCRIPTION="identify a file's format by scanning binary data for patterns"
HOMEPAGE="ftp://ftp.astron.com/pub/file/"
SRC_URI="ftp://ftp.astron.com/pub/file/${P}.tar.gz
	ftp://ftp.gw.com/mirrors/pub/unix/file/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="python static-libs zlib"

RDEPEND="zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}"

PYTHON_MODNAME="magic.py"

src_prepare() {
	epatch "${FILESDIR}"/${PN}-5.00-strtoull.patch
	# avoid eautoreconf when adding check for strtoull #263527
	sed -i 's/ strtoul / strtoul strtoull __strtoull /' configure
	sed -i "/#undef HAVE_STRTOUL\$/a#undef HAVE_STRTOULL\n#undef HAVE___STRTOULL" config.h.in

	[[ ${CHOST} == *-interix* ]] && eautoreconf # required for interix
	elibtoolize
	epunt_cxx

	# dont let python README kill main README #60043
	mv python/README{,.python}
}

usex() { use $1 && echo ${2:-yes} || echo ${3:-no} ; }

wd() { echo ${WORKDIR}/build-${CHOST}; }
do_configure() {
	ECONF_SOURCE=${S}

	mkdir "$(wd)"
	pushd "$(wd)" >/dev/null

	econf "$@"

	popd >/dev/null
}
src_configure() {
	# file uses things like strndup() and wcwidth()
	append-flags -D_GNU_SOURCE

	# when cross-compiling, we need to build up our own file
	# because people often don't keep matching host/target
	# file versions #362941
	if tc-is-cross-compiler && ! ROOT=/ has_version ~${CATEGORY}/${P} ; then
		ac_cv_header_zlib_h=no \
		ac_cv_lib_z_gzopen=no \
		CHOST=${CBUILD} \
		CFLAGS=${BUILD_CFLAGS} \
		CXXFLAGS=${BUILD_CXXFLAGS} \
		CPPFLAGS=${BUILD_CPPFLAGS} \
		LDFLAGS="${BUILD_LDFLAGS} -static" \
		do_configure --disable-shared
	fi

	export ac_cv_header_zlib_h=$(usex zlib) ac_cv_lib_z_gzopen=$(usex zlib)
	do_configure $(use_enable static-libs static)
}

do_make() {
	emake -C "$(wd)" "$@" || die
}
src_compile() {
	if tc-is-cross-compiler && ! ROOT=/ has_version ~${CATEGORY}/${P} ; then
		CHOST=${CBUILD} do_make -C src file
		PATH=$(CHOST=${CBUILD} wd)/src:${PATH}
	fi
	do_make

	use python && cd python && distutils_src_compile
}

src_install() {
	do_make DESTDIR="${D}" install || die
	dodoc ChangeLog MAINT README

	use python && cd python && distutils_src_install
	use static-libs || rm -f "${ED}"/usr/lib*/libmagic.la
}

pkg_postinst() {
	use python && distutils_pkg_postinst
}

pkg_postrm() {
	use python && distutils_pkg_postrm
}
