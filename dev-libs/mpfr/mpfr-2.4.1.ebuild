# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/mpfr/mpfr-2.4.1.ebuild,v 1.1 2009/02/26 03:08:40 vapier Exp $

# NOTE: we cannot depend on autotools here starting with gcc-4.3.x
inherit eutils

MY_PV=${PV/_p*}
MY_P=${PN}-${MY_PV}
PLEVEL=${PV/*p}
DESCRIPTION="library for multiple-precision floating-point computations with exact rounding"
HOMEPAGE="http://www.mpfr.org/"
SRC_URI="http://www.mpfr.org/mpfr-current/${MY_P}.tar.lzma"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=dev-libs/gmp-4.1.4-r2"
DEPEND="${RDEPEND}
	app-arch/lzma-utils"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	[[ -d ${FILESDIR}/${PV} ]] && epatch "${FILESDIR}"/${PV}/*.patch
	[[ ${PLEVEL} == ${PV} ]] && return 0
	for ((i=1; i<=PLEVEL; ++i)) ; do
		patch=patch$(printf '%02d' ${i})
		if [[ -f ${FILESDIR}/${MY_PV}/${patch} ]] ; then
			epatch "${FILESDIR}"/${MY_PV}/${patch}
		elif [[ -f ${DISTDIR}/${PN}-${MY_PV}_p${i} ]] ; then
			epatch "${DISTDIR}"/${PN}-${MY_PV}_p${i}
		else
			ewarn "${DISTDIR}/${PN}-${MY_PV}_p${i}"
			die "patch ${i} missing - please report to bugs.gentoo.org"
		fi
	done
	find . -type f -print0 | xargs -0 touch -r configure
}

src_install() {
	emake install DESTDIR="${D}" || die
	dodoc AUTHORS BUGS ChangeLog NEWS README TODO
	dohtml *.html
}
