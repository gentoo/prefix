# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/a2ps/a2ps-4.13c-r5.ebuild,v 1.20 2008/01/25 19:32:00 grobian Exp $

EAPI="prefix"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit eutils autotools

S=${WORKDIR}/${PN}-${PV:0:4}
DESCRIPTION="Any to PostScript filter"
HOMEPAGE="http://www.inf.enst.fr/~demaille/a2ps/"
SRC_URI="mirror://gentoo/${P}.tar.gz
	cjk? ( http://dev.gentoo.org/~usata/distfiles/${P}-ja_nls.patch.gz ) "

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="nls tetex cjk vanilla userland_BSD userland_GNU"

DEPEND=">=dev-util/gperf-2.7.2
	|| ( >=dev-util/yacc-1.9.1 sys-devel/bison )
	virtual/ghostscript
	>=app-text/psutils-1.17
	tetex? ( virtual/tetex )
	nls? ( sys-devel/gettext )"
RDEPEND="virtual/ghostscript
	userland_GNU? ( || ( >=sys-apps/coreutils-6.10-r1 sys-apps/mktemp ) )
	userland_BSD? ( sys-freebsd/freebsd-ubin )
	>=app-text/psutils-1.17
	tetex? ( virtual/tetex )
	nls? ( virtual/libintl )"

src_unpack() {
	unpack ${P}.tar.gz
	cd ${S}

	epatch ${FILESDIR}/${PN}-4.13-select-freebsd.patch
	epatch ${FILESDIR}/${P}-locale-gentoo.diff
	epatch ${FILESDIR}/${PN}-4.13c-stdarg.patch
	use vanilla || epatch ${FILESDIR}/${PN}-4.13-stdout.diff
	epatch ${FILESDIR}/${PV}-gcc34.patch
	use cjk && epatch ${DISTDIR}/${P}-ja_nls.patch.gz

	# improve tempfile handling
	epatch ${FILESDIR}/${P}-fixps.patch
	epatch ${FILESDIR}/${P}-psmandup.diff

	# fix fnmatch replacement, bug #134546
	epatch ${FILESDIR}/${P}-fnmatch-replacement.patch

	# fix sandbox violation, bug #79012
	sed -i -e 's:$acroread -helpall:acroread4 -helpall:' configure configure.in

	# fix emacs printing, bug #114627
	epatch ${FILESDIR}/a2ps-4.13c-emacs.patch

	# fix psset with sed-4.1, bug #126403
	epatch ${FILESDIR}/a2ps-4.13c-psset.patch

	# fix >=autoconf-2.60, bug 138161
	epatch ${FILESDIR}/a2ps-4.13-fixcachecheck.patch

	# fix chmod error, #167670
	epatch ${FILESDIR}/a2ps-4.13-manpage-chmod.patch

	AT_M4DIR="m4" eautoreconf || die "eautoreconf failed"
}

src_compile() {
	addpredict /usr/$(get_libdir)/mozilla-firefox/components/xpti.dat
	addpredict /usr/$(get_libdir)/mozilla-firefox/components/xpti.dat.tmp
	addpredict /usr/$(get_libdir)/mozilla-firefox/components/compreg.dat.tmp

	addpredict /usr/$(get_libdir)/mozilla/components/xpti.dat
	addpredict /usr/$(get_libdir)/mozilla/components/xpti.dat.tmp

	#export YACC=yacc
	econf --sysconfdir="${EPREFIX}"/etc/a2ps \
		--includedir="${EPREFIX}"/usr/include \
		`use_enable nls` || die "econf failed"

	export LANG=C

	# sometimes emake doesn't work
	make || die "make failed"
}

src_install() {
	dodir /usr/share/emacs/site-lisp

	einstall \
		sysconfdir=${ED}/etc/a2ps \
		includedir=${ED}/usr/include \
		lispdir=${ED}/usr/share/emacs/site-lisp \
		|| die "einstall failed"

	dosed /etc/a2ps/a2ps.cfg

	# bug #122026
	sed -i "s:^countdictstack: \0:" ${ED}/usr/bin/psset || die "sed failed"

	dodoc ANNOUNCE AUTHORS ChangeLog FAQ NEWS README* THANKS TODO
}
