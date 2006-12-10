# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-crypt/gnupg/gnupg-1.4.6.ebuild,v 1.9 2006/12/08 19:58:58 dang Exp $

EAPI="prefix"

inherit eutils flag-o-matic

ECCVER=0.1.6
ECCVER_GNUPG=1.4.5
MY_P=${P/_/}

DESCRIPTION="The GNU Privacy Guard, a GPL pgp replacement"
HOMEPAGE="http://www.gnupg.org/"
SRC_URI="mirror://gnupg/gnupg/${P}.tar.bz2
	!bindist? (
		idea? ( ftp://ftp.gnupg.dk/pub/contrib-dk/idea.c.gz )
		ecc? ( http://alumnes.eps.udl.es/%7Ed4372211/src/${PN}-${ECCVER_GNUPG}-ecc${ECCVER}.diff.bz2 )
		)"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos"
IUSE="bzip2 bindist curl ecc idea ldap nls readline selinux smartcard static usb zlib X linguas_ru"

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

src_unpack() {
	unpack ${A}

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
			epatch "${FILESDIR}"/${P}-ecc-helper.patch
			EPATCH_OPTS="-p1 -d ${S}" epatch ${PN}-${ECCVER_GNUPG}-ecc${ECCVER}.diff
		fi
	fi

	# maketest fix
	EPATCH_OPTS="-p1 -d ${S}" epatch "${FILESDIR}"/${PN}-1.4.3-selftest.patch

	# install RU man page in right location
	EPATCH_OPTS="-p1 -d ${S}" epatch "${FILESDIR}"/${P}-badruman.patch

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
	ewarn "If you are using a non-Linux system, or a kernel older than 2.6.9,"
	ewarn "you MUST make the gpg binary setuid."
	echo
	if use !bindist && use idea; then
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
	if use !bindist && use ecc; then
		einfo
		ewarn "The elliptical curves patch is experimental"
		einfo "Further info available at http://alumnes.eps.udl.es/%7Ed4372211/index.en.html"
	fi
	einfo
	einfo "See http://www.gentoo.org/doc/en/gnupg-user.xml for documentation on gnupg"
	einfo
}
