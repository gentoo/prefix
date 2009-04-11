# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/gnulib/gnulib-9999.ebuild,v 1.2 2007/10/28 21:03:33 vapier Exp $

inherit eutils autotools

DESCRIPTION="Gnulib is a library of common routines intended to be shared at the source level."
HOMEPAGE="http://www.gnu.org/software/gnulib"

# This tar.gz is created on-the-fly when downloaded from
# http://git.savannah.gnu.org/gitweb/?p=gnulib.git;a=snapshot;h=${GNULIB_COMMIT_GITID};sf=tgz
# So to have persistent checksums, we need to download once and cache it.
#
# To get a new version, download a "snapshot" from
# http://git.savannah.gnu.org/gitweb/?p=gnulib.git
# take the commit-id as GNULIB_COMMIT_GITID
# and the committer's timestamp (not the author's one), year to second, UTC
# as the ebuild version.
#
# To see what the last commit message for the current version was, use
# http://git.savannah.gnu.org/gitweb/?p=gnulib.git;a=commit;h=${GNULIB_COMMIT_GITID}
#
RESTRICT=mirror
GNULIB_COMMIT_GITID=5490f5a9848076555e5cdac9b6613b9d107a6ac2
SRC_URI="http://dev.gentoo.org/~haubi/distfiles/${PN}-${GNULIB_COMMIT_GITID}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~ia64-hpux ~x86-interix ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}"/${PN}
MY_S="${WORKDIR}"/${P}

src_unpack() {
	unpack ${A}
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
