# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/gnulib/gnulib-9999-r1.ebuild,v 1.3 2009/02/02 18:55:47 drizzt Exp $

EGIT_REPO_URI="git://git.savannah.gnu.org/gnulib.git"

inherit eutils git autotools

DESCRIPTION="Gnulib is a library of common routines intended to be shared at the source level."
HOMEPAGE="http://www.gnu.org/software/gnulib"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}"/${PN}
MY_S="${WORKDIR}"/${P}

src_unpack() {
	git_src_unpack
	cd "${S}" || die
	epatch "${FILESDIR}"/${PN}-2008.07.23-rpl_getopt.patch

	"${S}"/gnulib-tool --create-testdir --dir="${MY_S}" \
		getopt \
		strcasestr \
		xvasprintf \
	|| die

	cd "${MY_S}" || die

	# define both libgnu.a and the headers as to-be-installed
	LANG=C \
	sed -e '
		s,noinst_HEADERS,include_HEADERS,;
		s,noinst_LIBRARIES,lib_LIBRARIES,;
		s,noinst_LTLIBRARIES,lib_LTLIBRARIES,;
		s,EXTRA_DIST =$,&\
EXTRA_HEADERS =,;
		s,BUILT_SOURCES += \([/a-zA-Z0-9_-][/a-zA-Z0-9_-]*\.h\|\$([_A-Z0-9][_A-Z0-9]*_H)\)$,&\
include_HEADERS += \1,;
	' -i gllib/Makefile.am || die "cannot fix gllib/Makefile.am"

	eautoreconf
}

src_compile() {
	emake -C doc info html || die "emake failed"
	cd "${MY_S}" || die
	econf --prefix="${EPREFIX}"/usr/$(get_libdir)/${PN}
	emake || die "cannot make ${P}"
}

src_install() {
	dodoc README COPYING ChangeLog
	dohtml doc/gnulib.html
	doinfo doc/gnulib.info

	insinto /usr/share/${PN}
	doins -r lib
	doins -r m4
	doins -r modules
	doins -r build-aux
	doins -r top

	# remove CVS dirs
	#find "${ED}" -name CVS -type d -print0 | xargs -0 rm -r

	# install the real script
	exeinto /usr/share/${PN}
	doexe gnulib-tool

	# create and install the wrapper
	dosym /usr/share/${PN}/gnulib-tool /usr/bin/gnulib-tool

	cd "${MY_S}" || die
	emake install DESTDIR="${D}" || die "make install failed"
}
