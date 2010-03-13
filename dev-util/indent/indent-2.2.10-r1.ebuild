# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/indent/indent-2.2.10-r1.ebuild,v 1.10 2010/02/13 16:23:34 armin76 Exp $

EAPI="2"

inherit autotools eutils

DESCRIPTION="Indent program source files"
HOMEPAGE="http://www.gnu.org/software/indent/indent.html"
SRC_URI="mirror://gnu/indent/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="nls"

DEPEND="nls? ( sys-devel/gettext )"
RDEPEND="nls? ( virtual/libintl )"

src_prepare() {
	# Fix parallel make issue in man/ (bug #76610)
	epatch "${FILESDIR}"/${PV}-man.patch
	# Make texinfo2man behave when insufficient arguments are fed
	epatch "${FILESDIR}"/${PV}-segfault.patch
	eautoreconf

	# comply to the standard
	cp -a man/texinfo2man.c{,.orig} || die
	sed -i -e 's/<malloc\.h>/<stdlib.h>/' man/texinfo2man.c || die
	touch -r man/texinfo2man.c{.orig,} || die # avoid regen
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
