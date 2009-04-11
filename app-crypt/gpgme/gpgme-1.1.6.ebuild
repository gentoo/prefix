# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/gpgme/gpgme-1.1.6.ebuild,v 1.9 2009/03/17 08:17:29 dragonheart Exp $

inherit autotools eutils

DESCRIPTION="GnuPG Made Easy is a library for making GnuPG easier to use"
HOMEPAGE="http://www.gnupg.org/related_software/gpgme"
SRC_URI="mirror://gnupg/gpgme/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="1"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="pth"

DEPEND=">=dev-libs/libgpg-error-1.4
	>=app-crypt/gnupg-1.9.20-r1
	pth? ( >=dev-libs/pth-1.2 )"

RDEPEND="${DEPEND}
	dev-libs/libgcrypt"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}/${P}-cvs.patch"
	epatch "${FILESDIR}/${P}-darwin.patch"
	chmod a+x "tests/gpg/pinentry"
	AT_M4DIR=m4 eautoreconf

	# We need to call elibtoolize so that we get sane .so versioning on fbsd.
	#elibtoolize
	cd gpgme
	epatch "${FILESDIR}/${PN}-1.1.8-et_EE.patch"
}

src_compile() {
	econf \
		--includedir="${EPREFIX}"/usr/include/gpgme \
		--with-gpg="${EPREFIX}"/usr/bin/gpg \
		--with-gpgsm="${EPREFIX}"/usr/bin/gpgsm \
		$(use_with pth) \
		|| die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NEWS README THANKS TODO VERSION
}
