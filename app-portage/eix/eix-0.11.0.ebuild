# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-portage/eix/eix-0.11.0.ebuild,v 1.1 2008/03/05 09:03:19 genstef Exp $

EAPI=prefix

DESCRIPTION="Small utility for searching ebuilds with indexing for fast results"
HOMEPAGE="http://eix.sourceforge.net"
SRC_URI="mirror://sourceforge/eix/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~ia64-hpux ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="sqlite"

DEPEND="sqlite? ( >=dev-db/sqlite-3 )
	app-arch/bzip2"
RDEPEND="${DEPEND}"

src_compile() {
	econf --with-bzip2 $(use_with sqlite) \
		--with-portdir-cache-method=none \
		--with-eprefix-default="${EPREFIX}" \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	dodoc AUTHORS ChangeLog TODO
}

pkg_postinst() {
	elog "As of >=eix-0.5.4, \"metadata\" is the new default cache."
	elog "It's independent of the portage-version and the cache used by portage."
	elog "But as in Prefix this cache is not available, in Prefix this default"
	elog "is set to \"none\" instead!"

	elog /etc/eixrc will not get updated anymore by the eix ebuild.
	elog Upstream strongly recommends to remove this file resp. to keep
	elog only those entries which you want to differ from the defaults.
	elog Use options --dump or --dump-defaults to get an output analogous
	elog to previous /etc/eixrc files.
}
