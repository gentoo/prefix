# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/indent/indent-2.2.11.ebuild,v 1.5 2010/05/12 14:50:48 jer Exp $

EAPI="2"

inherit eutils

DESCRIPTION="Indent program source files"
HOMEPAGE="http://indent.isidore-it.eu/beautify.html"
SRC_URI="http://${PN}.isidore-it.eu/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="nls"

DEPEND="
	nls? ( sys-devel/gettext )
	app-text/texi2html
"
RDEPEND="nls? ( virtual/libintl )"

src_prepare() {
	epatch "${FILESDIR}"/${PV}-segfault.patch

#	# comply to the standard
#	cp -a man/texinfo2man.c{,.orig} || die
#	sed -i -e 's/<malloc\.h>/<stdlib.h>/' man/texinfo2man.c || die
#	touch -r man/texinfo2man.c{.orig,} || die # avoid regen
}

src_configure() {
	# LINGUAS is used in aclocal.m4 (bug #94837)
	unset LINGUAS
	econf $(use_enable nls) || die "configure failed"
}

src_test() {
	emake -C regression/ || die "regression tests failed"
}

src_install() {
	emake \
		DESTDIR="${D}" \
		htmldir="${EPREFIX}/usr/share/doc/${PF}/html" \
		install || die "make install failed"
	dodoc AUTHORS NEWS README* ChangeLog*
}
