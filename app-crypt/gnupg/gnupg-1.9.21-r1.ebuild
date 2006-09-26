# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/gnupg/gnupg-1.9.21-r1.ebuild,v 1.2 2006/09/24 09:55:36 dragonheart Exp $

EAPI="prefix"

inherit eutils flag-o-matic autotools

DESCRIPTION="The GNU Privacy Guard, a GPL pgp replacement"
HOMEPAGE="http://www.gnupg.org/"
SRC_URI="mirror://gnupg/alpha/gnupg/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="1.9"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="X gpg2-experimental ldap nls openct pcsc-lite smartcard selinux"
#IUSE+=caps

COMMON_DEPEND="
	virtual/libc
	>=dev-libs/pth-1.3.7
	>=dev-libs/libgcrypt-1.1.94
	>=dev-libs/libksba-0.9.15
	>=dev-libs/libgpg-error-1.0
	~dev-libs/libassuan-0.6.10
	pcsc-lite? ( >=sys-apps/pcsc-lite-1.3.0 )
	openct? ( >=dev-libs/openct-0.5.0 )
	ldap? ( net-nds/openldap )"
# Needs sh and arm to be keyworded on pinentry
#	X? ( app-crypt/pinentry )
#	caps? ( sys-libs/libcap )"

DEPEND="${COMMON_DEPEND}
	nls? ( sys-devel/gettext )"

RDEPEND="${COMMON_DEPEND}
	!app-crypt/gpg-agent
	=app-crypt/gnupg-1.4*
	X? ( || ( media-gfx/xloadimage media-gfx/xli ) )
	virtual/mta
	selinux? ( sec-policy/selinux-gnupg )
	nls? ( virtual/libintl )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	sed -i -e 's/PIC/__PIC__/g' intl/relocatable.c || die "PIC patching failed"

	# this warning is only available on gcc4!
	sed -i -e '/AM_CFLAGS/s!-Wno-pointer-sign!!g' ${S}/g10/Makefile.am
	sed -i -e '/AM_CFLAGS/s!-Wno-pointer-sign!!g' ${S}/g10/Makefile.in

	epatch "${FILESDIR}/${PN}-1.9.20-fbsd.patch"
	#epatch "${FILESDIR}/${P}-fbsd-gcc41.patch"
	AT_M4DIR="m4 gl/m4" eautoreconf
}

src_compile() {
	local myconf=""

	if use X; then
		local viewer
		if has_version 'media-gfx/xloadimage'; then
			viewer="${EPREFIX}"/usr/bin/xloadimage
		else
			viewer="${EPREFIX}"/usr/bin/xli
		fi
		myconf="${myconf} --with-photo-viewer=${viewer}"
	else
		myconf="${myconf} --disable-photo-viewers"
	fi

	#use caps || append-ldflags $(bindnow-flags)
	append-ldflags $(bindnow-flags)

	# the Darwin linker finds that this is not in the final linking phase...
	append-ldflags -lpth

	#$(use_with caps capabilities) \
	econf \
		--enable-agent \
		--enable-symcryptrun \
		$(use_enable gpg2-experimental gpg) \
		--enable-gpgsm \
		$(use_enable smartcard scdaemon) \
		$(use_enable nls) \
		$(use_enable ldap) \
		--disable-capabilities \
		${myconf} \
		|| die
	emake || die
}

src_install() {
	make DESTDIR="${EDEST}" install || die
	dodoc ChangeLog NEWS README THANKS TODO VERSION

	#if ! use caps; then
		use gpg2-experimental && fperms u+s,go-r /usr/bin/gpg2
		fperms u+s,go-r /usr/bin/gpg-agent
	#fi
}

pkg_postinst() {
	#if ! use caps; then
	#	einfo "gpg is installed suid root to make use of protected memory space"
	#	einfo "This is needed in order to have a secure place to store your"
	#	einfo "passphrases, etc. at runtime but may make some sysadmins nervous."
	#fi
	einfo
	einfo "See http://www.gentoo.org/doc/en/gnupg-user.xml for documentation on gnupg"
	einfo
}
