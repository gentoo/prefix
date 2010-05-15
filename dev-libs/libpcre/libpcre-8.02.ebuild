# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libpcre/libpcre-8.02.ebuild,v 1.1 2010/05/03 20:15:39 patrick Exp $

EAPI=2

inherit libtool eutils toolchain-funcs

DESCRIPTION="Perl-compatible regular expression library"
HOMEPAGE="http://www.pcre.org/"
if [[ ${PV} == ${PV/_rc} ]]
then
	MY_P="pcre-${PV}"
	SRC_URI="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${MY_P}.tar.bz2"
else
	MY_P="pcre-${PV/_rc/-RC}"
	SRC_URI="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/Testing/${MY_P}.tar.bz2"
fi
LICENSE="BSD"
SLOT="3"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="bzip2 +cxx unicode zlib static-libs"

RDEPEND="bzip2? ( app-arch/bzip2 )
	zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	userland_GNU? ( >=sys-apps/findutils-4.4.0 )"

S=${WORKDIR}/${MY_P}

src_prepare() {
	sed -i -e "s:libdir=@libdir@:libdir=${EPREFIX}/$(get_libdir):" libpcre.pc.in || die "Fixing libpcre pkgconfig files failed"
	sed -i -e "s:-lpcre ::" libpcrecpp.pc.in || die "Fixing libpcrecpp pkgconfig files failed"
}

src_configure() {
	# IRIX needs some help...
	if [[ ${CHOST} == mips-sgi-irix* ]]; then
		export ac_cv_func_strtoll=no            # C99 only
		export lt_cv_prog_compiler_c_o=yes
		export lt_cv_prog_compiler_c_o_CXX=yes
		export ac_cv_type_long_long=no          # missing strtoll
		export ac_cv_type_unsigned_long_long=no # missing strtoll
	fi

	[[ ${CHOST} == *-mint* ]] && CXXFLAGS="${CXXFLAGS} -D_GNU_SOURCE"

	# Enable building of static libs too - grep and others
	# depend on them being built: bug 164099
	econf --with-match-limit-recursion=8192 \
		$(use_enable unicode utf8) $(use_enable unicode unicode-properties) \
		$(use_enable cxx cpp) \
		$(use_enable zlib pcregrep-libz) \
		$(use_enable bzip2 pcregrep-libbz2) \
		$(use_enable static-libs static) \
		--enable-shared \
		--htmldir="${EPREFIX}"/usr/share/doc/${PF}/html \
		--docdir="${EPREFIX}"/usr/share/doc/${PF} \
		|| die "econf failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	gen_usr_ldscript -a pcre
	find "${ED}" -type f -name '*.la' -exec rm -rf '{}' '+' || die "la removal failed"
}

pkg_postinst() {
	elog "This version of ${PN} has stopped installing .la files. This may"
	elog "cause compilation failures in other packages. To fix this problem,"
	elog "install dev-util/lafilefixer and run:"
	elog "lafilefixer --justfixit"
}
