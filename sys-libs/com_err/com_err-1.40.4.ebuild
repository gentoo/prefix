# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/com_err/com_err-1.40.4.ebuild,v 1.8 2008/03/17 19:19:36 phreak Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs

DESCRIPTION="common error display library"
HOMEPAGE="http://e2fsprogs.sourceforge.net/"
SRC_URI="mirror://sourceforge/e2fsprogs/e2fsprogs-${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="nls"

RDEPEND=""
DEPEND="nls? ( sys-devel/gettext )
	sys-devel/bc"

S=${WORKDIR}/e2fsprogs-${PV}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.39-makefile.patch
	epatch "${FILESDIR}"/${PN}-1.40-darwin-makefile.patch
}

src_compile() {
	export LDCONFIG="${EPREFIX}"/bin/true
	export CC=$(tc-getCC)
	export STRIP="${EPREFIX}"/bin/true

	# We want to use the "bsd" libraries while building on Darwin, but while
	# building on other Gentoo/*BSD we prefer elf-naming scheme.
	local libtype
	case ${CHOST} in
		*-darwin*) libtype=bsd;;
		*)         libtype=elf;;
	esac

	econf \
		--enable-${libtype}-shlibs \
		--with-ldopts="${LDFLAGS}" \
		$(use_enable !elibc_uclibc tls) \
		$(use_enable nls) \
		|| die
	emake -j1 -C lib/et || die
}

src_test() {
	make -C lib/et check || die "make check failed"
}

src_install() {
	export LDCONFIG="${EPREFIX}"/bin/true
	export CC=$(tc-getCC)
	export STRIP="${EPREFIX}"/bin/true

	make -C lib/et DESTDIR="${D}" install || die
	dosed '/^ET_DIR=/s:=.*:='"${EPREFIX}"'/usr/share/et:' /usr/bin/compile_et
	dosym et/com_err.h /usr/include/com_err.h

	dolib.a lib/libcom_err.a || die "dolib.a"
	dodir /$(get_libdir)
	mv "${ED}"/usr/$(get_libdir)/*$(get_libname)* "${ED}"/$(get_libdir)/ || die "move $(get_libname)"
	gen_usr_ldscript libcom_err$(get_libname)
}

pkg_postinst() {
	echo
	ewarn "PLEASE PLEASE take note of this"
	ewarn "Please make *sure* to run revdep-rebuild now"
	ewarn "Certain things on your system may have linked against a"
	ewarn "different version of com_err -- those things need to be"
	ewarn "recompiled.  Sorry for the inconvenience"
	echo
	epause 10
	ebeep
}
