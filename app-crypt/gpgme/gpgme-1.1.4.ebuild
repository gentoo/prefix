# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/gpgme/gpgme-1.1.4.ebuild,v 1.1 2007/03/13 16:47:12 alonbl Exp $

EAPI="prefix"

inherit eutils libtool

DESCRIPTION="GnuPG Made Easy is a library for making GnuPG easier to use"
HOMEPAGE="http://www.gnupg.org/(en)/related_software/gpgme/index.html"
SRC_URI="mirror://gnupg/gpgme/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE=""

DEPEND=">=dev-libs/libgpg-error-1.4
	>=dev-libs/pth-1.2
	>=app-crypt/gnupg-1.9.20-r1"

RDEPEND="${DEPEND}
	dev-libs/libgcrypt"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${PN}-1.1.3-fbsd.patch"
	epatch "${FILESDIR}"/${P}-darwin7.patch

	# We need to call elibtoolize so that we get sane .so versioning on fbsd.
	elibtoolize
}

src_compile() {
	if use selinux; then
		sed -i -e "s:tests = tests:tests = :" Makefile.in || die "sed failed"
	fi

	econf \
		--includedir=${EPREFIX}/usr/include/gpgme \
		--with-gpg=${EPREFIX}/usr/bin/gpg \
		--with-pth=yes \
		--with-gpgsm=${EPREFIX}/usr/bin/gpgsm \
		|| die "econf failed"
	emake CFLAGS="${CFLAGS} -I../assuan/"  || die "emake failed"
}

src_install() {
	make DESTDIR=${D} install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO VERSION
}
