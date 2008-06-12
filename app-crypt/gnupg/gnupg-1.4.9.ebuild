# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/gnupg/gnupg-1.4.9.ebuild,v 1.7 2008/05/06 14:42:10 jer Exp $

EAPI="prefix"

inherit eutils flag-o-matic toolchain-funcs

ECCVER="0.2.0"
ECCVER_GNUPG="1.4.8"
ECC_PATCH="${PN}-${ECCVER_GNUPG}-ecc${ECCVER}.diff"
MY_P=${P/_/}

DESCRIPTION="The GNU Privacy Guard, a GPL pgp replacement"
HOMEPAGE="http://www.gnupg.org/"
SRC_URI="mirror://gnupg/gnupg/${P}.tar.bz2
	!bindist? (
		idea? ( ftp://ftp.gnupg.dk/pub/contrib-dk/idea.c.gz )
		ecc? ( http://www.calcurco.cat/eccGnuPG/src/${ECC_PATCH}.bz2 )
		)"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~x86-macos"
IUSE="bzip2 bindist curl ecc idea ldap nls readline selinux smartcard static usb zlib linguas_ru"

COMMON_DEPEND="
	ldap? ( net-nds/openldap )
	bzip2? ( app-arch/bzip2 )
	zlib? ( sys-libs/zlib )
	curl? ( net-misc/curl )
	virtual/mta
	readline? ( sys-libs/readline )
	smartcard? ( dev-libs/libusb )
	usb? ( dev-libs/libusb )"

RDEPEND="!static? ( ${COMMON_DEPEND} )
	selinux? ( sec-policy/selinux-gnupg )
	nls? ( virtual/libintl )"

DEPEND="${COMMON_DEPEND}
	dev-lang/perl
	nls? ( sys-devel/gettext )"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	if use idea; then
		if use bindist; then
			einfo "Skipping IDEA support to comply with binary distribution (bug #148907)."
		else
			ewarn "Please read http://www.gnupg.org/(en)/faq/why-not-idea.html"
			mv "${WORKDIR}"/idea.c "${S}"/cipher/idea.c || \
			ewarn "failed to insert IDEA module"
		fi
	fi

	if use ecc; then
		if use bindist; then
			einfo "Skipping ECC patch to comply with binary distribution (bug #148907)."
		else
			sed -i \
				"s/- VERSION='${ECCVER_GNUPG}'/- VERSION='${PV}'/" \
				"${WORKDIR}/${ECC_PATCH}"
			sed -i \
				"s/+ VERSION='${ECCVER_GNUPG}-ecc${ECCVER}'/+ VERSION='${PV}-ecc${ECCVER}'/" \
				"${WORKDIR}/${ECC_PATCH}"

			epatch "${WORKDIR}/${ECC_PATCH}"
		fi
	fi

	# install RU man page in right location
	epatch "${FILESDIR}"/${PN}-1.4.6-badruman.patch

	# Fix PIC definitions
	sed -i -e 's:PIC:__PIC__:' mpi/i386/mpih-{add,sub}1.S intl/relocatable.c
	sed -i -e 's:if PIC:ifdef __PIC__:' mpi/sparc32v8/mpih-mul{1,2}.S
}

src_compile() {
	# Certain sparc32 machines seem to have trouble building correctly with
	# -mcpu enabled.  While this is not a gnupg problem, it is a temporary
	# fix until the gcc problem can be tracked down.
	if [ "${ARCH}" == "sparc" ] && [ "${PROFILE_ARCH}" == "sparc" ]; then
		filter-flags -mcpu=supersparc -mcpu=v8 -mcpu=v7
	fi

	# 'USE=static' support was requested in #29299
	use static &&append-ldflags -static

	econf \
		--docdir="/usr/share/doc/${PF}" \
		$(use_enable ldap) \
		--enable-mailto \
		--enable-hkp \
		--enable-finger \
		$(use_with !zlib included-zlib) \
		$(use_with curl libcurl /usr) \
		$(use_enable nls) \
		$(use_enable bzip2) \
		$(use_enable smartcard card-support) \
		$(use_enable selinux selinux-support) \
		--disable-capabilities \
		$(use_with readline) \
		$(use_with usb libusb /usr) \
		$(use_enable static) \
		--enable-static-rnd=linux \
		--libexecdir="${EPREFIX}"/usr/libexec \
		--enable-noexecstack \
		CC_FOR_BUILD=$(tc-getBUILD_CC) \
		${myconf} || die
	# this is because it will run some tests directly
	emake || die
}

src_install() {
	make DESTDIR="${D}" install || die

	# keep the documentation in /usr/share/doc/...
	rm -rf "${ED}/usr/share/gnupg/FAQ" "${ED}/usr/share/gnupg/faq.html"

	dodoc AUTHORS BUGS ChangeLog NEWS PROJECTS README THANKS \
		TODO VERSION doc/{FAQ,HACKING,DETAILS,OpenPGP,faq.raw}

	dohtml doc/faq.html

	exeinto /usr/libexec/gnupg
	doexe tools/make-dns-cert

	# install RU documentation in right location
	if use linguas_ru; then
		cp doc/gpg.ru.1 "${T}/gpg.1"
		doman -i18n=ru "${T}/gpg.1"
	fi
}

pkg_postinst() {
	ewarn "If you are using a non-Linux system, or a kernel older than 2.6.9,"
	ewarn "you MUST make the gpg binary setuid."
	echo
	if use !bindist && use idea; then
		elog
		elog "IDEA"
		elog "you have compiled ${PN} with support for the IDEA algorithm, this code"
		elog "is distributed under the GPL in countries where it is permitted to do so"
		elog "by law."
		elog
		elog "Please read http://www.gnupg.org/(en)/faq/why-not-idea.html for more information."
		elog
		ewarn "If you are in a country where the IDEA algorithm is patented, you are permitted"
		ewarn "to use it at no cost for 'non revenue generating data transfer between private"
		ewarn "individuals'."
		ewarn
		ewarn "Countries where the patent applies are listed here"
		ewarn "http://en.wikipedia.org/wiki/International_Data_Encryption_Algorithm#Security"
		ewarn
		ewarn "Further information and other licenses are availble from http://www.mediacrypt.com/"
		ewarn
	fi
	if use !bindist && use ecc; then
		ewarn
		ewarn "The elliptical curves patch is experimental"
		ewarn "Further info available at http://alumnes.eps.udl.es/%7Ed4372211/index.en.html"
	fi
	elog
	elog "See http://www.gentoo.org/doc/en/gnupg-user.xml for documentation on gnupg"
	elog
	elog "If you wish to view images emerge:"
	elog "media-gfx/xloadimage, media-gfx/xli or any other viewer"
	elog "Remember to use photo-viewer option in configuration file to activate the right viewer"
}
