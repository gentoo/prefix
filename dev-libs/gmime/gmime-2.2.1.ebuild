# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/gmime/gmime-2.2.1.ebuild,v 1.4 2006/08/29 17:39:41 ferdy Exp $

EAPI="prefix"

inherit gnome2 eutils mono

IUSE="doc ipv6 mono"
DESCRIPTION="Utilities for creating and parsing messages using MIME"
SRC_URI="http://spruce.sourceforge.net/gmime/sources/v${PV%.*}/${P}.tar.gz"
HOMEPAGE="http://spruce.sourceforge.net/gmime/"

SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"

RDEPEND=">=dev-libs/glib-2
	doc? ( >=dev-util/gtk-doc-1.0 )
	mono? ( dev-lang/mono
			>=dev-dotnet/gtk-sharp-2.4.0 )
	sys-libs/zlib"

DEPEND="dev-util/pkgconfig
	doc? ( app-text/docbook-sgml-utils )
	${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd ${S}

	if use doc ; then
		#db2html should be docbook2html
		sed -i -e 's:db2html:docbook2html -o gmime-tut:g' \
			docs/tutorial/Makefile.am docs/tutorial/Makefile.in \
			|| die "sed failed (1)"
		# Fix doc targets (bug #97154)
		sed -i -e 's!\<\(tmpl-build.stamp\): !\1 $(srcdir)/tmpl/*.sgml: !' \
			gtk-doc.make docs/reference/Makefile.in || die "sed failed (3)"
	fi

	# Use correct libdir for mono assembly
	sed -i -e 's:^libdir.*:libdir=@libdir@:' \
		-e 's:^prefix=:exec_prefix=:' \
		-e 's:prefix)/lib:libdir):' \
		mono/gmime-sharp.pc.in mono/Makefile.{am,in} || die "sed failed (2)"
}

src_compile() {
	econf \
	    `use_enable ipv6` \
		`use_enable mono` \
	    `use_enable doc gtk-doc` || die "configure failed"
	MONO_PATH=${S} emake -j1 || die
}

src_install() {
	make GACUTIL_FLAGS="${EPREFIX}/root ${ED}/usr/$(get_libdir) ${EPREFIX}/gacdir ${EPREFIX}/usr/$(get_libdir) ${EPREFIX}/package ${EPREFIX}/${PN}" \
		DESTDIR=${D} install || die

	if use doc ; then
		# we don't use docinto/dodoc, because we don't want html doc gzipped
		insinto /usr/share/doc/${PF}/tutorial
		doins docs/tutorial/html/*
	fi

	# rename these two, so they don't conflict with app-arch/sharutils
	# (bug #70392)	Ticho, 2004-11-10
	mv ${ED}/usr/bin/uuencode ${ED}/usr/bin/gmime-uuencode
	mv ${ED}/usr/bin/uudecode ${ED}/usr/bin/gmime-uudecode
}

DOCS="AUTHORS ChangeLog COPYING INSTALL NEWS PORTING README TODO doc/html/"
