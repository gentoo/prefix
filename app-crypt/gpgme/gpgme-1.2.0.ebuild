# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/gpgme/gpgme-1.2.0.ebuild,v 1.1 2009/06/22 01:33:48 arfrever Exp $

EAPI="2"

inherit libtool eutils autotools

DESCRIPTION="GnuPG Made Easy is a library for making GnuPG easier to use"
HOMEPAGE="http://www.gnupg.org/related_software/gpgme"
SRC_URI="mirror://gnupg/gpgme/${P}.tar.gz"

LICENSE="GPL-2 LGPL-2.1"
SLOT="1"
KEYWORDS="~x64-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x86-solaris"
IUSE="pth"

DEPEND=">=dev-libs/libgpg-error-1.4
	app-crypt/gnupg
	pth? ( >=dev-libs/pth-1.2 )"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}/${PN}-1.1.8-et_EE.patch"
	epatch "${FILESDIR}/${P}-fix_implicit_declaration.patch"

	# Call elibtoolize to get sane .so versioning on FreeBSD.
	elibtoolize
}

src_configure() {
	econf \
		--includedir="${EPREFIX}"/usr/include/gpgme \
		--with-gpg="${EPREFIX}"/usr/bin/gpg \
		--with-gpgsm="${EPREFIX}"/usr/bin/gpgsm \
		$(use_with pth)
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO
}
