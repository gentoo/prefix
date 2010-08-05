# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-text/rarian/rarian-0.8.1.ebuild,v 1.12 2010/07/20 15:07:11 jer Exp $

inherit eutils gnome2 autotools

DESCRIPTION="A documentation metadata library"
HOMEPAGE="http://www.freedesktop.org"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""

RDEPEND="dev-libs/libxslt"
DEPEND="${RDEPEND}
	!<app-text/scrollkeeper-9999"

DOCS="ChangeLog NEWS README"

GCONF=""

src_unpack() {
	# You cannot run src_unpack from gnome2; it will break the install by
	# calling gnome2_omf_fix
	unpack ${A}
	cd "${S}"

	eautoreconf # need new libtool for interix

	# remove unneeded line, bug #240564
	sed "s/ (foreign dist-bzip2 dist-gzip)//" -i configure || die "sed failed"

	elibtoolize ${ELTCONF}
}

src_compile() {
	gnome2_src_compile --localstatedir="${EPREFIX}"/var
}
