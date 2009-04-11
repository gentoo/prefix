# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/ferite/ferite-1.0.2.ebuild,v 1.11 2008/10/29 11:23:14 flameeyes Exp $

inherit multilib

DESCRIPTION="A clean, lightweight, object oriented scripting language"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"
HOMEPAGE="http://www.ferite.org/"

DEPEND="virtual/libc
	>=dev-libs/libpcre-5
	dev-libs/libxml2"

SLOT="1"
LICENSE="as-is"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE=""

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e '/^fbmdir/s:$(prefix)/share/doc/ferite:${EPREFIX}/usr/share/doc/${PF}:' Makefile.in
	sed -i -e 's:$(prefix)/share/doc/ferite:${ED}/usr/share/doc/${PF}:' docs/Makefile.in
	sed -i -e '/$(docsdir)/s:$(DESTDIR)::' docs/Makefile.in
	sed -i -e '/$(docsDATA_INSTALL)/s:$(DESTDIR)::' docs/Makefile.in
	sed -i -e '/^LDFLAGS/s:LDFLAGS:#LDFLAGS:' modules/stream/Makefile.in
	sed -i -e '/^testscriptsdir/s:$(prefix)/share/doc/ferite/:${EPREFIX}/usr/share/doc/${PF}/:' \
		scripts/test/Makefile.in
	sed -i -e '/^testscriptsdir/s:$(prefix)/share/doc/ferite/:${EPREFIX}/usr/share/doc/${PF}/:' \
		scripts/test/rmi/Makefile.in
	sed -i -e "s|\$prefix/lib|\$prefix/$(get_libdir)|g" configure
}

src_compile() {
	econf --libdir="${EPREFIX}"/usr/$(get_libdir)|| die
	# Parallel make issues, see bug #244871
	emake -j1 || die
}

src_install() {
	cp tools/doc/feritedoc "${T}"
	sed -i -e '/^prefix/s:prefix:${T}' -e "${T}"/feritedoc
	sed -i -e '/^$prefix/s:$prefix/bin/ferite:{ED}/usr/bin/ferite:' -e "${T}"/feritedoc
	sed -i -e 's:build_c_api_docs.sh $(prefix)/bin/:build_c_api_docs.sh ${T}/:' docs/Makefile.in
	make DESTDIR="${D}" LIBDIR="${EPREFIX}"/usr/$(get_libdir) install || die
}
