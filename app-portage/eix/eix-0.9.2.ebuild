# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/eix/eix-0.9.2.ebuild,v 1.1 2007/04/06 00:45:41 genstef Exp $

EAPI=prefix
DESCRIPTION="Small utility for searching ebuilds with indexing for fast results"
HOMEPAGE="http://dev.croup.de/proj/eix"
SRC_URI="mirror://sourceforge/eix/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86-macos ~x86"
IUSE="sqlite"

DEPEND="sqlite? ( >=dev-db/sqlite-3 )"
RDEPEND="${DEPEND}"

src_compile() {
	econf \
		--with-portdir-cache-method=none \
		--with-eprefix-default=${EPREFIX} \
		$(use_with sqlite) || die "econf failed"
	emake || die "emake failed"
	src/eix --dump-defaults >eixrc || die "generating eixrc failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog TODO

	insinto /etc
	doins eixrc
}

pkg_postinst() {
	einfo "As of >=eix-0.5.4, \"metadata\" is the new default cache."
	einfo "It's independent of the portage-version and the cache used by portage."
}
