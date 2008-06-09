# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libpcre/libpcre-7.7.ebuild,v 1.1 2008/05/26 14:16:24 loki_val Exp $

EAPI="prefix 1"

inherit libtool eutils

MY_P="pcre-${PV}"

DESCRIPTION="Perl-compatible regular expression library"
HOMEPAGE="http://www.pcre.org/"
SRC_URI="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${MY_P}.tar.bz2"

LICENSE="BSD"
SLOT="3"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x86-solaris"
IUSE="bzip2 +cxx doc unicode zlib"

DEPEND="dev-util/pkgconfig"
RDEPEND=""

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	elibtoolize
}

src_compile() {
	# IRIX needs some help...
	if [[ ${CHOST} == mips-sgi-irix* ]]; then
		export ac_cv_func_strtoll=no            # C99 only
		export lt_cv_prog_compiler_c_o=yes
		export lt_cv_prog_compiler_c_o_CXX=yes
		export ac_cv_type_long_long=no          # missing strtoll
		export ac_cv_type_unsigned_long_long=no # missing strtoll
	fi
	# Enable building of static libs too - grep and others
	# depend on them being built: bug 164099
	econf --with-match-limit-recursion=8192 \
		$(use_enable unicode utf8) $(use_enable unicode unicode-properties) \
		$(use_enable cxx cpp) \
		$(use_enable zlib pcregrep-libz) \
		$(use_enable bzip2 pcregrep-libbz2) \
		--enable-static \
		--htmldir="${EPREFIX}"/usr/share/doc/${PF}/html \
		--docdir="${EPREFIX}"/usr/share/doc/${PF} \
		|| die "econf failed"
	emake all || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	dodoc doc/*.txt AUTHORS
	use doc && dohtml doc/html/*
}
