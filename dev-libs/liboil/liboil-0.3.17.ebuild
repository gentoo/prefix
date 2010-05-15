# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/liboil/liboil-0.3.17.ebuild,v 1.1 2010/04/16 14:18:14 ssuominen Exp $

EAPI=2
inherit flag-o-matic

DESCRIPTION="library of simple functions that are optimized for various CPUs"
HOMEPAGE="http://liboil.freedesktop.org/"
SRC_URI="http://liboil.freedesktop.org/download/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0.3"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="doc +examples test"

RDEPEND="examples? ( dev-libs/glib:2 )"
DEPEND="${RDEPEND}
	doc? ( >=dev-util/gtk-doc-1 )"

src_prepare() {
	if ! use examples; then
		sed "s/^\(SUBDIRS =.*\)examples\(.*\)$/\1\2/" \
			-i Makefile.am Makefile.in || die
	fi

	if ! use test; then
		sed "s/^\(SUBDIRS =.*\)testsuite\(.*\)$/\1\2/" \
			-i Makefile.am Makefile.in || die
	fi
}

src_configure() {
	strip-flags
	filter-flags -O?
	append-flags -O2

	econf \
		--disable-dependency-tracking \
		$(use_enable doc gtk-doc) \
		--with-html-dir="${EPREFIX}"/usr/share/doc/${PF}/html
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS BUG-REPORTING HACKING NEWS README || die
}

pkg_postinst() {
	if ! use examples; then
		ewarn "You have disabled examples USE flag. Beware that upstream might"
		ewarn "want the output of some utilities that are only built with"
		ewarn "USE='examples' if you report bugs to them."
	fi
}
