# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/a2ps/a2ps-4.14.ebuild,v 1.7 2008/05/12 15:05:17 jer Exp $

EAPI="prefix"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="latest"

inherit eutils autotools elisp-common

S=${WORKDIR}/${PN}-${PV:0:4}
DESCRIPTION="Any to PostScript filter"
HOMEPAGE="http://www.inf.enst.fr/~demaille/a2ps/"
SRC_URI="mirror://gnu/${PN}/${P}.tar.gz
	cjk? ( mirror://gentoo/${P}-ja_nls.patch.gz )"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~mips-linux ~x86-linux ~ppc-macos"
IUSE="cjk emacs nls latex vanilla userland_BSD userland_GNU"

DEPEND=">=dev-util/gperf-2.7.2
	|| ( >=dev-util/yacc-1.9.1 sys-devel/bison )
	virtual/ghostscript
	>=app-text/psutils-1.17
	emacs? ( virtual/emacs )
	latex? ( virtual/latex-base )
	nls? ( sys-devel/gettext )"
RDEPEND="virtual/ghostscript
	app-text/wdiff
	userland_GNU? ( || ( >=sys-apps/coreutils-6.10-r1 sys-apps/mktemp ) )
	userland_BSD? ( sys-freebsd/freebsd-ubin )
	>=app-text/psutils-1.17
	emacs? ( virtual/emacs )
	latex? ( virtual/latex-base )
	nls? ( virtual/libintl )"

SITEFILE=50${PN}-gentoo.el

src_unpack() {
	unpack ${P}.tar.gz
	cd "${S}"

	epatch "${FILESDIR}/${PN}-4.13c-locale-gentoo.diff"
	# this will break
	#epatch "${FILESDIR}/${PN}-4.13c-stdarg.patch"
	use vanilla || epatch "${FILESDIR}/${PN}-4.13-stdout.diff"
	use cjk && epatch "${DISTDIR}/${P}-ja_nls.patch.gz"

	# fix fnmatch replacement, bug #134546
	epatch "${FILESDIR}/${PN}-4.13c-fnmatch-replacement.patch"

	# fix sandbox violation, bug #79012
	sed -i -e 's:$acroread -helpall:acroread4 -helpall:' configure configure.in

	# fix emacs printing, bug #114627
	epatch "${FILESDIR}/a2ps-4.13c-emacs.patch"

	# fix chmod error, #167670
	epatch "${FILESDIR}/a2ps-4.13-manpage-chmod.patch"

	# add configure check for mempcpy, bug 216588
	epatch "${FILESDIR}/${P}-check-mempcpy.patch"

	# fix compilation error due to invalid stpcpy() prototype, bug 216588
	epatch "${FILESDIR}/${P}-fix-stpcpy-proto.patch"

	AT_M4DIR="m4" eautoreconf || die "eautoreconf failed"
}

src_compile() {
	#export YACC=yacc
	export COM_netscape=no
	use latex || COM_latex=no
	econf --sysconfdir="${EPREFIX}"/etc/a2ps \
		--includedir="${EPREFIX}"/usr/include \
		$(useq emacs || echo EMACS=no) \
		$(use_enable nls) || die "econf failed"

	export LANG=C

	# sometimes emake doesn't work
	make || die "make failed"
}

src_install() {
	einstall \
		sysconfdir="${ED}"/etc/a2ps \
		includedir="${ED}"/usr/include \
		lispdir="${ED}${SITELISP}/${PN}" \
		|| die "einstall failed"

	dosed /etc/a2ps/a2ps.cfg

	# bug #122026
	sed -i "s:^countdictstack: \0:" "${ED}"/usr/bin/psset || die "sed failed"

	if use emacs; then
		elisp-site-file-install "${FILESDIR}/${SITEFILE}" \
			|| die "elisp-site-file-install failed"
	fi

	dodoc ANNOUNCE AUTHORS ChangeLog FAQ NEWS README* THANKS TODO
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
