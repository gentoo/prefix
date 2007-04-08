# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/gnupg/gnupg-2.0.3-r1.ebuild,v 1.1 2007/04/02 09:00:32 alonbl Exp $

EAPI="prefix"

inherit flag-o-matic

DESCRIPTION="The GNU Privacy Guard, a GPL pgp replacement"
HOMEPAGE="http://www.gnupg.org/"
SRC_URI="mirror://gnupg/gnupg/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-solaris"
IUSE="bzip2 doc ldap nls openct pcsc-lite smartcard selinux"

COMMON_DEPEND="
	virtual/libc
	>=dev-libs/pth-1.3.7
	>=dev-libs/libgcrypt-1.2.0
	>=dev-libs/libksba-1.0.0
	>=dev-libs/libgpg-error-1.4
	>=dev-libs/libassuan-1.0.1
	>=net-misc/curl-7.7.2
	bzip2? ( app-arch/bzip2 )
	pcsc-lite? ( >=sys-apps/pcsc-lite-1.3.0 )
	openct? ( >=dev-libs/openct-0.5.0 )
	ldap? ( net-nds/openldap )
	app-crypt/pinentry"

DEPEND="${COMMON_DEPEND}
	nls? ( sys-devel/gettext )
	doc? ( sys-apps/texinfo )"

RDEPEND="${COMMON_DEPEND}
	!app-crypt/gpg-agent
	!<=app-crypt/gnupg-2.0.1
	virtual/mta
	selinux? ( sec-policy/selinux-gnupg )
	nls? ( virtual/libintl )"

src_compile() {

	append-ldflags $(bindnow-flags)

	# symcryptrun does some non-portable stuff, which breaks on Solaris,
	# disable for now, can't easily come up with a patch
	[[ ${CHOST} != *-solaris* ]] \
		&& myconf="${myconf} --enable-symcryptrun" \
		|| myconf="${myconf} --disable-symcryptrun"

	econf \
		--enable-gpg \
		--enable-gpgsm \
		--enable-agent \
		$(use_enable bzip2) \
		$(use_enable smartcard scdaemon) \
		$(use_enable nls) \
		$(use_enable ldap) \
		--disable-capabilities \
		${myconf} \
		|| die
	emake || die
	if use doc; then
		cd doc
		emake html || die
	fi
}

src_install() {
	make DESTDIR="${D}" install || die
	dodoc ChangeLog NEWS README THANKS TODO VERSION

	dosym gpg2 /usr/bin/gpg
	dosym gpgv2 /usr/bin/gpgv
	echo ".so man1/gpg2.1" > "${ED}/usr/share/man/man1/gpg.1"
	echo ".so man1/gpgv2.1" > "${ED}/usr/share/man/man1/gpgv.1"

	use doc && dohtml doc/gnupg.html/* doc/*jpg doc/*png
}

pkg_postinst() {
	elog "If you wish to view images emerge:"
	elog "media-gfx/xloadimage, media-gfx/xli or any other viewer"
	elog "Remember to use photo-viewer option in configuration file to activate the right viewer"
}
