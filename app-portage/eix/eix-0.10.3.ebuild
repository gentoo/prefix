# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/eix/eix-0.10.3.ebuild,v 1.2 2008/01/01 14:18:23 mr_bones_ Exp $

EAPI=prefix

inherit eutils autotools

DESCRIPTION="Small utility for searching ebuilds with indexing for fast results"
HOMEPAGE="http://dev.croup.de/proj/eix"
SRC_URI="mirror://sourceforge/eix/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ia64-hpux ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="sqlite"

DEPEND="sqlite? ( >=dev-db/sqlite-3 )
	app-arch/bzip2"
RDEPEND="${DEPEND}"

src_compile() {
	econf \
		--with-portdir-cache-method=none \
		--with-eprefix-default="${EPREFIX}" \
		--with-bzip2 $(use_with sqlite) || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog TODO
}

pkg_postinst() {
	einfo "As of >=eix-0.5.4, \"metadata\" is the new default cache."
	einfo "It's independent of the portage-version and the cache used by portage."

	elog /etc/eixrc will not get updated anymore by the eix ebuild.
	elog Upstream strongly recommends to remove this file resp. to keep
	elog only those entries which you want to differ from the defaults.
	elog Use options --dump or --dump-defaults to get an output analogous
	elog to previous /etc/eixrc files.
}
