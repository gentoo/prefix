# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"

inherit eutils flag-o-matic autotools

DESCRIPTION="a small but very powerful text-based mail client"
HOMEPAGE="http://www.mutt.org"
SRC_URI="http://dev.mutt.org/nightlies/mutt-${P#*_p}.tar.gz
	!vanilla? (
		mirror://gentoo/mutt-1.5.13-gentoo-patches.tar.bz2
	)"
IUSE="berkdb buffysize cjk crypt debug gdbm gnutls gpgme idn imap mbox nls nntp pop sasl smime smtp ssl vanilla"
SLOT="0"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-solaris"
RDEPEND="nls? ( sys-devel/gettext )
	>=sys-libs/ncurses-5.2
	gdbm?    ( sys-libs/gdbm )
	!gdbm?   ( berkdb? ( >=sys-libs/db-4 ) )
	imap?    (
		gnutls?  ( >=net-libs/gnutls-1.0.17 )
		!gnutls? ( ssl? ( >=dev-libs/openssl-0.9.6 ) )
		sasl?    ( >=dev-libs/cyrus-sasl-2 )
	)
	pop?     (
		gnutls?  ( >=net-libs/gnutls-1.0.17 )
		!gnutls? ( ssl? ( >=dev-libs/openssl-0.9.6 ) )
		sasl?    ( >=dev-libs/cyrus-sasl-2 )
	)
	idn?     ( net-dns/libidn )
	gpgme?   ( >=app-crypt/gpgme-0.9.0 )
	smime?   ( >=dev-libs/openssl-0.9.6 )
	app-misc/mime-types"
DEPEND="${RDEPEND}
	net-mail/mailbase"

S="${WORKDIR}"/mutt-1.5.14cvs
PATCHDIR="${WORKDIR}"/mutt-1.5.13-gentoo-patches

src_unpack() {
	unpack ${A}
	cd "${S}" || die "unpack failed"

	# back out stupid Debian patch, it causes bus-errors
	EPATCH_OPTS="-R" epatch "${FILESDIR}"/mutt-1.5.14-debian-hcache.patch
	# avoid this warning to allow commpilation on amd64
	epatch "${FILESDIR}"/mutt-1.5.14-util.c-64bit-compile-warning.patch

	epatch "${FILESDIR}"/mutt-1.5.13-smarttime.patch
	# this patch is non-generic and only works because we use a sysconfdir
	# different from the one used by the mailbase ebuild
	epatch "${FILESDIR}"/mutt-1.5.13-prefix-mailcap.patch
	# try out this behaviour
	epatch "${FILESDIR}"/mutt-1.5.14-change-folder-next.patch

	if ! use vanilla ; then
		if ! use nntp ; then
			rm "${PATCHDIR}"/07-vvv.nntp-gentoo.patch
			rm "${PATCHDIR}"/08-mixmaster_nntp.patch
		fi
		# these are broken with recent snapshots
		rm "${PATCHDIR}"/03-compressed.patch
		rm "${PATCHDIR}"/05-mbox_hook.patch
		rm "${PATCHDIR}"/06-pgp_timeout.patch
		# already in CVS
		rm "${PATCHDIR}"/01-assumed_charset.patch

		for p in "${PATCHDIR}"/*.patch ; do
			epatch "${p}"
		done

		AT_M4DIR="m4" eautoreconf
	else
		eautoconf
	fi

	# this should be done only when we're not root
	sed -i \
		-e 's/@DOTLOCK_GROUP@/'"`id -gn`"'/g' \
		Makefile.in \
		|| die "sed failed"
}

src_compile() {
	declare myconf="
		$(use_enable nls) \
		$(use_enable gpgme) \
		$(use_enable imap) \
		$(use_enable pop) \
		$(use_enable crypt pgp) \
		$(use_enable smime) \
		$(use_enable cjk default-japanese) \
		$(use_enable debug) \
		$(use_enable smtp) \
		$(use_with idn) \
		--with-curses \
		--sysconfdir=${EPREFIX}/etc/${PN} \
		--with-docdir=${EPREFIX}/usr/share/doc/${PN}-${PVR} \
		--with-regex \
		--disable-fcntl --enable-flock \
		--enable-nfs-fix --enable-external-dotlock \
		--with-mixmaster"

	case $CHOST in
		*-darwin7)
			# locales are broken on Panther
			myconf="${myconf} --enable-locales-fix --without-wc-funcs"
		;;
	esac

	# See Bug #22787
	unset WANT_AUTOCONF_2_5 WANT_AUTOCONF

	# mutt prioritizes gdbm over bdb, so we will too.
	# hcache feature requires at least one database is in USE.
	if use gdbm; then
		myconf="${myconf} --enable-hcache --with-gdbm --without-bdb"
	elif use berkdb; then
		myconf="${myconf} --enable-hcache --with-bdb --without-gdbm"
	else
		myconf="${myconf} --disable-hcache --without-gdbm --without-bdb"
	fi

	# there's no need for gnutls, ssl or sasl without either pop or imap.
	# in fact mutt's configure will bail if you do:
	#   --without-pop --without-imap --with-ssl
	if use pop || use imap; then
		if use gnutls; then
			myconf="${myconf} --with-gnutls"
		elif use ssl; then
			myconf="${myconf} --with-ssl"
		fi
		# not sure if this should be mutually exclusive with the other two
		myconf="${myconf} $(use_with sasl)"
	else
		myconf="${myconf} --without-gnutls --without-ssl --without-sasl"
	fi

	# See Bug #11170
	case ${ARCH} in
		alpha|ppc) replace-flags "-O[3-9]" "-O2" ;;
	esac

	if use buffysize; then
		ewarn "USE=buffy-size is just a workaround. Disable it if you don't need it."
		myconf="${myconf} --enable-buffy-size"
	fi

	if use mbox; then
		myconf="${myconf} --with-mailpath=/var/spool/mail"
	else
		myconf="${myconf} --with-homespool=Maildir"
	fi

	if ! use vanilla; then
		# rr.compressed patch
		myconf="${myconf} --enable-compressed"

		# nntp patch
		myconf="${myconf} $(use_enable nntp)"
	fi

	econf ${myconf} || die "configure failed"
	emake -j1 || die "make failed"
}

src_install() {
	make DESTDIR="${D}" install || die "install failed"
	find "${ED}"/usr/share/doc -type f | grep -v "html\|manual" | xargs gzip
	if use mbox; then
		insinto /etc/mutt
		newins "${FILESDIR}"/Muttrc.mbox Muttrc
	else
		insinto /etc/mutt
		doins "${FILESDIR}"/Muttrc
	fi

	# A newer file is provided by app-misc/mime-types. So we link it.
	rm "${ED}"/etc/${PN}/mime.types
	dosym /etc/mime.types /etc/${PN}/mime.types

	dodoc BEWARE COPYRIGHT ChangeLog NEWS OPS* PATCHES README* TODO VERSION
}

pkg_postinst() {
	echo
	einfo "If you are new to mutt you may want to take a look at"
	einfo "the Gentoo QuickStart Guide to Mutt E-Mail:"
	einfo "   http://www.gentoo.org/doc/en/guide-to-mutt.xml"
	echo
}
