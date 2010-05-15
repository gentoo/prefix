# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-util/gtk-doc/gtk-doc-1.13-r2.ebuild,v 1.2 2010/05/04 15:40:00 tester Exp $

EAPI="2"

inherit eutils elisp-common gnome2

DESCRIPTION="GTK+ Documentation Generator"
HOMEPAGE="http://www.gtk.org/gtk-doc/"

LICENSE="GPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x64-solaris"
IUSE="debug doc emacs test"

RDEPEND=">=dev-libs/glib-2.6
	>=dev-lang/perl-5.6
	>=app-text/openjade-1.3.1
	dev-libs/libxslt
	>=dev-libs/libxml2-2.3.6
	~app-text/docbook-xml-dtd-4.3
	app-text/docbook-xsl-stylesheets
	~app-text/docbook-sgml-dtd-3.0
	>=app-text/docbook-dsssl-stylesheets-1.40
	emacs? ( virtual/emacs )"

DEPEND="${RDEPEND}
	~dev-util/gtk-doc-am-${PV}
	>=dev-util/pkgconfig-0.19
	>=app-text/scrollkeeper-0.3.14
	>=app-text/gnome-doc-utils-0.3.2
	test? ( app-text/scrollkeeper-dtd )"

SITEFILE=61${PN}-gentoo.el

DOCS="AUTHORS ChangeLog MAINTAINERS NEWS README TODO"

pkg_setup() {
	G2CONF="--with-xml-catalog=${EPREFIX}/etc/xml/catalog"
}

src_prepare() {
	gnome2_src_prepare

	# Remove global Emacs keybindings.
	epatch "${FILESDIR}/${PN}-1.8-emacs-keybindings.patch"

	# gtk-doc.make puts $(DOC_MODULE)-overrides.txt in EXTRA_DIST,
	# so this file must exist to be able to "make dist".
	# fix bug #305191, upstream ##590625.
	epatch "${FILESDIR}/${P}-scan-touch-module-overrides.patch"
	# This restores a compatible behavior with previous versions of gtk-doc,
	# which is required by many tarballs, fix bug #305191, upstream #605211
	epatch "${FILESDIR}/${P}-fixxref-compat.patch"

	# Fix bug 306569 by not loading vim plugins while calling vim in
	# gtkdoc-fixxref for fixing vim syntax highlighting
	epatch "${FILESDIR}/${P}-fixxref-vim-u-NONE.patch"
}

src_install() {
	gnome2_src_install

	# Don't install those files, they are in gtk-doc-am now
	rm "${ED}"/usr/share/aclocal/gtk-doc.m4 || die "failed to remove gtk-doc.m4"
	rm "${ED}"/usr/bin/gtkdoc-rebase || die "failed to remove gtkdoc-rebase"

	if use doc; then
		docinto doc
		dodoc doc/*
		docinto examples
		dodoc examples/*
	fi

	if use emacs; then
		elisp-install ${PN} tools/gtk-doc.el*
		elisp-site-file-install "${FILESDIR}/${SITEFILE}"
	fi
}

pkg_postinst() {
	if use emacs; then
		elisp-site-regen
		elog "gtk-doc does no longer define global key bindings for Emacs."
		elog "You may set your own key bindings for \"gtk-doc-insert\" and"
		elog "\"gtk-doc-insert-section\" in your ~/.emacs file."
	fi
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
