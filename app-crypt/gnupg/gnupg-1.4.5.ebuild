# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/gnupg/gnupg-1.4.5.ebuild,v 1.10 2006/10/24 18:32:17 grobian Exp $

EAPI="prefix"

inherit eutils flag-o-matic linux-info

ECCVER=0.1.6
ECCVER_GNUPG=1.4.4
MY_P=${P/_/}

DESCRIPTION="The GNU Privacy Guard, a GPL pgp replacement"
HOMEPAGE="http://www.gnupg.org/"
SRC_URI="mirror://gnupg/gnupg/${P}.tar.bz2
	idea? ( ftp://ftp.gnupg.dk/pub/contrib-dk/idea.c.gz )
	ecc? ( http://alumnes.eps.udl.es/%7Ed4372211/src/${PN}-${ECCVER_GNUPG}-ecc${ECCVER}.diff.bz2 )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE="bzip2 curl ecc idea ldap nls readline selinux smartcard static usb zlib X linguas_ru"
# IUSE+=caps

#	caps? ( sys-libs/libcap )
COMMON_DEPEND="
	ldap? ( net-nds/openldap )
	bzip2? ( app-arch/bzip2 )
	zlib? ( sys-libs/zlib )
	curl? ( net-misc/curl )
	virtual/mta
	readline? ( sys-libs/readline )
	smartcard? ( dev-libs/libusb )
	usb? ( dev-libs/libusb )"

RDEPEND="!static? (
		${COMMON_DEPEND}
		X? ( || ( media-gfx/xloadimage media-gfx/xli ) )
	)
	selinux? ( sec-policy/selinux-gnupg )
	nls? ( virtual/libintl )"

DEPEND="${COMMON_DEPEND}
	dev-lang/perl
	nls? ( sys-devel/gettext )"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	# fix bug #113474 - no compiled kernel needed now
	if use kernel_linux; then
	    get_running_version
	fi
}

src_unpack() {
	unpack ${A}


	# Jari's patch to boost iterated key setup by factor of 128
	EPATCH_OPTS="-p1 -d ${S}" epatch "${FILESDIR}"/${PN}-1.4.3-jari.patch

	if use idea; then
		ewarn "Please read http://www.gnupg.org/(en)/faq/why-not-idea.html"
		mv "${WORKDIR}"/idea.c "${S}"/cipher/idea.c || \
			ewarn "failed to insert IDEA module"
	fi

	if use ecc; then
		epatch "${FILESDIR}"/${P}-ecc-helper.patch
		EPATCH_OPTS="-p1 -d ${S}" epatch ${PN}-${ECCVER_GNUPG}-ecc${ECCVER}.diff
	fi

	# maketest fix
	EPATCH_OPTS="-p1 -d ${S}" epatch "${FILESDIR}"/${PN}-1.4.3-selftest.patch

	# install RU man page in right location
	EPATCH_OPTS="-p1 -d ${S}" epatch "${FILESDIR}"/${PN}-1.4.3-badruman.patch

	# keyserver fix
	EPATCH_OPTS="-p1 -d ${S}"  epatch "${FILESDIR}"/${PN}-1.4.3-keyserver.patch

	cd "${S}"
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

	append-ldflags $(bindnow-flags)

	# fix compile problem on ppc64
	use ppc64 && myconf="${myconf} --disable-asm"

	#	$(use_with caps capabilities) \
	econf \
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
		$(use_enable X photo-viewers) \
		--enable-static-rnd=linux \
		--libexecdir="${EPREFIX}"/usr/libexec \
		--enable-noexecstack \
		${myconf} || die
	# this is because it will run some tests directly
	gnupg_fixcheckperms
	emake || die
}

src_install() {
	gnupg_fixcheckperms
	make DESTDIR="${D}" install || die

	# keep the documentation in /usr/share/doc/...
	rm -rf "${ED}/usr/share/gnupg/FAQ" "${ED}/usr/share/gnupg/faq.html"

	dodoc AUTHORS BUGS ChangeLog NEWS PROJECTS README THANKS \
		TODO VERSION doc/{FAQ,HACKING,DETAILS,ChangeLog,OpenPGP,faq.raw}

	docinto sgml
	dodoc doc/*.sgml

	dohtml doc/faq.html

	exeinto /usr/libexec/gnupg
	doexe tools/make-dns-cert

	# install RU documentation in right location
	if use linguas_ru
	then
		cp doc/gpg.ru.1 ${T}/gpg.1
		doman -i18n=ru ${T}/gpg.1
	fi
}

gnupg_fixcheckperms() {
	# GnuPG does weird things for testing that it build correctly
	# as we as for the additional tests. It WILL fail with perms 770 :-(.
	# See bug #80044
	if has userpriv ${FEATURES}; then
		einfo "Fixing permissions in check directory"
		chown -R portage:portage ${S}/checks
		chmod -R ugo+rw ${S}/checks
		chmod ugo+rw ${S}/checks
	fi
}

src_test() {
	gnupg_fixcheckperms
	einfo "Running tests"
	emake check
	ret=$?
	if [ $ret -ne 0 ]; then
		die "Some tests failed! Please report to the Gentoo Bugzilla"
	fi
}

pkg_postinst() {
	#if ! use kernel_linux || (! use caps && kernel_is lt 2 6 9); then
	if ! use kernel_linux || kernel_is lt 2 6 9; then
		chmod u+s,go-r ${EROOT}/usr/bin/gpg
		einfo "gpg is installed suid root to make use of protected memory space"
		einfo "This is needed in order to have a secure place to store your"
		einfo "passphrases, etc. at runtime but may make some sysadmins nervous."
	else
		chmod u-s,go-r ${EROOT}/usr/bin/gpg
	fi
	echo
	if use idea; then
		einfo "-----------------------------------------------------------------------------------"
		einfo "IDEA"
		ewarn "you have compiled ${PN} with support for the IDEA algorithm, this code"
		ewarn "is distributed under the GPL in countries where it is permitted to do so"
		ewarn "by law."
		einfo
		einfo "Please read http://www.gnupg.org/(en)/faq/why-not-idea.html for more information."
		einfo
		ewarn "If you are in a country where the IDEA algorithm is patented, you are permitted"
		ewarn "to use it at no cost for 'non revenue generating data transfer between private"
		ewarn "individuals'."
		einfo
		einfo "Countries where the patent applies are listed here"
		einfo "http://www.mediacrypt.com/_contents/10_idea/101030_ea_pi.asp"
		einfo
		einfo "Further information and other licenses are availble from http://www.mediacrypt.com/"
		einfo "-----------------------------------------------------------------------------------"
	fi
	if use ecc; then
		einfo
		ewarn "The elliptical curves patch is experimental"
		einfo "Further info available at http://alumnes.eps.udl.es/%7Ed4372211/index.en.html"
	fi
	#if use caps; then
	#	einfo
	#	ewarn "Capabilities code is experimental"
	#fi
	einfo
	einfo "See http://www.gentoo.org/doc/en/gnupg-user.xml for documentation on gnupg"
	einfo
}
