# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/mpfr/mpfr-2.4.2_p3.ebuild,v 1.1 2010/01/24 19:06:38 vapier Exp $

# NOTE: we cannot depend on autotools here starting with gcc-4.3.x
inherit eutils libtool

MY_PV=${PV/_p*}
MY_P=${PN}-${MY_PV}
PLEVEL=${PV/*p}
DESCRIPTION="library for multiple-precision floating-point computations with exact rounding"
HOMEPAGE="http://www.mpfr.org/"
SRC_URI="http://www.mpfr.org/mpfr-current/${MY_P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND=">=dev-libs/gmp-4.1.4-r2"
DEPEND="${RDEPEND}"

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
	sed -i '/if test/s:==:=:' configure #261016
	find . -type f -print0 | xargs -0 touch -r configure

# fails to apply	epatch "${FILESDIR}"/${PN}-2.4.1_p5-interix.patch

	# http://bugs.gentoo.org/307907, can't do this unconditional for now
	[[ ${CHOST} == *-mint* ]] && elibtoolize
}

src_install() {
	emake install DESTDIR="${D}" || die
	rm "${ED}"/usr/share/doc/${PN}/*.html || die
	mv "${ED}"/usr/share/doc/{${PN},${PF}} || die
	dodoc AUTHORS BUGS ChangeLog NEWS README TODO
	dohtml *.html
	prepalldocs
}
