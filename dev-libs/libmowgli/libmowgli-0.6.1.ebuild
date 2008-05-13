# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libmowgli/libmowgli-0.6.1.ebuild,v 1.7 2008/05/12 14:23:24 corsair Exp $

EAPI="prefix"

inherit flag-o-matic

DESCRIPTION="High-performance C development framework. Can be used stand-alone or as a supplement to GLib."
HOMEPAGE="http://www.atheme.org/projects/mowgli.shtml"
SRC_URI="http://distfiles.atheme.org/${P}.tgz"
IUSE="examples"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~mips-linux ~x86-linux"

src_compile() {
	[[ ${CHOST} == *-interix* ]] && append-flags -D_ALL_SOURCE

	econf $(use_enable examples) \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS
}
