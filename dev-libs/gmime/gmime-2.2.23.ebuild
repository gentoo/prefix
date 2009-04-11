# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/gmime/gmime-2.2.23.ebuild,v 1.8 2009/01/26 23:06:53 loki_val Exp $

inherit gnome2 eutils mono libtool autotools

DESCRIPTION="Utilities for creating and parsing messages using MIME"
SRC_URI="http://spruce.sourceforge.net/${PN}/sources/v${PV%.*}/${P}.tar.gz"
HOMEPAGE="http://spruce.sourceforge.net/gmime/"

SLOT="0"
LICENSE="LGPL-2.1"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="doc mono"

RDEPEND=">=dev-libs/glib-2
	mono? ( dev-lang/mono
			>=dev-dotnet/gtk-sharp-2.4.0 )
	sys-libs/zlib"
DEPEND="${RDEPEND}
		dev-util/pkgconfig
		dev-util/gtk-doc-am
		doc? (
			>=dev-util/gtk-doc-1.0
			app-text/docbook-sgml-utils )"

DOCS="AUTHORS ChangeLog COPYING INSTALL NEWS PORTING README TODO doc/html/"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}/gmime-2.2.23-sign-assembly.patch"
	cp "${FILESDIR}/gmime-sharp.snk" mono/
	if use doc ; then
		#db2html should be docbook2html
		sed -i -e 's:db2html:docbook2html -o gmime-tut:g' \
			docs/tutorial/Makefile.am docs/tutorial/Makefile.in \
			|| die "sed failed (1)"
		# Fix doc targets (bug #97154)
		sed -i -e 's!\<\(tmpl-build.stamp\): !\1 $(srcdir)/tmpl/*.sgml: !' \
			gtk-doc.make docs/reference/Makefile.in || die "sed failed (3)"
	fi

	eautoreconf
	elibtoolize
}

src_compile() {
	econf $(use_enable mono) $(use_enable doc gtk-doc)
	MONO_PATH="${S}" emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "installation failed"

	if use doc ; then
		# we don't use docinto/dodoc, because we don't want html doc gzipped
		insinto /usr/share/doc/${PF}/tutorial
		doins docs/tutorial/html/*
	fi

	# rename these two, so they don't conflict with app-arch/sharutils
	# (bug #70392)	Ticho, 2004-11-10
	mv "${ED}/usr/bin/uuencode" "${ED}/usr/bin/gmime-uuencode"
	mv "${ED}/usr/bin/uudecode" "${ED}/usr/bin/gmime-uudecode"
	mono_multilib_comply
}
