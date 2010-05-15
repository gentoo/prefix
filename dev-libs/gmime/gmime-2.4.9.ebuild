# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/gmime/gmime-2.4.9.ebuild,v 1.8 2010/04/05 14:54:47 armin76 Exp $

inherit gnome2 eutils mono libtool

DESCRIPTION="Utilities for creating and parsing messages using MIME"
HOMEPAGE="http://spruce.sourceforge.net/gmime/"

SLOT="2.4"
LICENSE="LGPL-2.1"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="doc mono"

RDEPEND=">=dev-libs/glib-2.12
	sys-libs/zlib
	mono? (
		dev-lang/mono
		>=dev-dotnet/gtk-sharp-2.4.0 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	doc? (
		>=dev-util/gtk-doc-1.0
		app-text/docbook-sgml-utils )
	mono? ( dev-dotnet/gtk-sharp-gapi )"

DOCS="AUTHORS ChangeLog COPYING INSTALL NEWS PORTING README TODO doc/html/"

src_unpack() {
	unpack ${A}
	cd "${S}"

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
		mono/gmime-sharp-2.4.pc.in mono/Makefile.{am,in} || die "sed failed (2)"

	elibtoolize
}

src_compile() {
	econf $(use_enable mono) $(use_enable doc gtk-doc)
	MONO_PATH="${S}" emake || die "emake failed"
}

src_install() {
	emake GACUTIL_FLAGS="${EPREFIX}/root '${ED}/usr/$(get_libdir)' ${EPREFIX}/gacdir ${EPREFIX}/usr/$(get_libdir) ${EPREFIX}/package ${PN}" \
		DESTDIR="${ED}" install || die "installation failed"

	if use doc ; then
		# we don't use docinto/dodoc, because we don't want html doc gzipped
		insinto /usr/share/doc/${PF}/tutorial
		doins docs/tutorial/html/*
	fi

	# rename these two, so they don't conflict with app-arch/sharutils
	# (bug #70392)	Ticho, 2004-11-10
	mv "${ED}/usr/bin/uuencode" "${ED}/usr/bin/gmime-uuencode-${SLOT}"
	mv "${ED}/usr/bin/uudecode" "${ED}/usr/bin/gmime-uudecode-${SLOT}"
}
