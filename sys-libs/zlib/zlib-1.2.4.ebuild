# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/zlib/zlib-1.2.4.ebuild,v 1.3 2010/03/19 19:09:37 ssuominen Exp $

inherit eutils toolchain-funcs

DESCRIPTION="Standard (de)compression library"
HOMEPAGE="http://www.zlib.net/"
SRC_URI="http://www.gzip.org/zlib/${P}.tar.bz2
	http://www.zlib.net/${P}.tar.bz2"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND="!<dev-libs/libxml2-2.7.7" #309623

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.2.3-mingw-implib.patch #288212
	epatch "${FILESDIR}"/${PN}-1.2.4-configure-LANG.patch
	# trust exit status of the compiler rather than stderr #55434
	# -if test "`(...) 2>&1`" = ""; then
	# +if (...) 2>/dev/null; then
	sed -i 's|if test "`\(.*\) 2>&1`" = ""; then|if \1 2>/dev/null; then|' configure || die
	sed -i -e '/ldconfig/d' Makefile* || die

	# also set soname and stuff on Solaris
	sed -i -e 's:Linux | linux:Linux | linux | SunOS:' configure || die
	# put libz.so.1 into libz.a on AIX
# fails, still necessary?
#	epatch "${FILESDIR}"/${PN}-1.2.3-shlib-aix.patch
}

src_compile() {
	tc-export AR CC RANLIB RC DLLWRAP
	case ${CHOST} in
	*-mingw*|mingw*)
		emake -f win32/Makefile.gcc prefix=/usr || die
		;;
	*-mint*)
		./configure --prefix="${EPREFIX}"/usr --libdir="${EPREFIX}"/$(get_libdir) || die
		emake || die
		;;
	*)  # not an autoconf script, so cant use econf
		./configure --shared --prefix="${EPREFIX}"/usr --libdir="${EPREFIX}"/usr/$(get_libdir) || die
		emake || die
		;;
	esac
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc FAQ README ChangeLog doc/*.txt

	case ${CHOST} in
	*-mingw*|mingw*)
		dobin zlib1.dll || die
		dolib libz.dll.a || die
		;;
	*-mint*)
		# no shared libraries here
		:
		;;
	*) gen_usr_ldscript -a z ;;
	esac

	# on winnt, additionally install the .dll files.
	if [[ ${CHOST} == *-winnt* ]]; then
		into /
		dolib libz$(get_libname ${PV}).dll
	fi
}
