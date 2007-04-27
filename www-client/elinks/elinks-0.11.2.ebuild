# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/elinks/elinks-0.11.2.ebuild,v 1.14 2007/04/25 13:44:25 eroyf Exp $

EAPI="prefix"

WANT_AUTOCONF="latest"
WANT_AUTOMAKE="1.4"

inherit eutils autotools flag-o-matic

MY_P="${P/_/}"
DESCRIPTION="Advanced and well-established text-mode web browser"
HOMEPAGE="http://elinks.or.cz/"
SRC_URI="http://elinks.or.cz/download/${MY_P}.tar.bz2
	http://dev.gentoo.org/~spock/portage/distfiles/elinks-0.10.4.conf.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-solaris"
IUSE="bittorrent bzip2 debug finger ftp gopher gpm guile idn ipv6 \
	  javascript lua nls nntp perl ruby ssl unicode X zlib"
RESTRICT="test"

DEPEND=">=dev-libs/expat-1.95.4
	bzip2? ( >=app-arch/bzip2-1.0.2 )
	ssl? ( >=dev-libs/openssl-0.9.6g )
	X? ( || ( ( x11-libs/libX11 x11-libs/libXt )
			virtual/x11 ) )
	zlib? ( >=sys-libs/zlib-1.1.4 )
	lua? ( >=dev-lang/lua-5 )
	gpm? ( >=sys-libs/ncurses-5.2 >=sys-libs/gpm-1.20.0-r5 )
	guile? ( >=dev-scheme/guile-1.6.4-r1 )
	idn? ( net-dns/libidn )
	perl? ( sys-devel/libperl )
	ruby? ( dev-lang/ruby )
	!hppa? ( !mips? ( !alpha? ( javascript? ( dev-lang/spidermonkey ) ) ) )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	if use guile && has_version ">dev-scheme/guile-1.6.8" &&
	   ! built_with_use -a dev-scheme/guile deprecated discouraged; then
		eerror "To install elinks with the 'guile' USE flag, dev-scheme/guile has to"
		eerror "be built with 'deprecated' and 'discouraged' USE flags."
		die "dev-scheme/guile not built with deprecated/discouraged"
	fi
}

src_unpack() {
	unpack ${A}
	epatch ${FILESDIR}/${PN}-0.10.4.conf-syscharset.diff
	mv "${PN}-0.10.4.conf" "${PN}.conf"
	if ! use ftp ; then
		sed -i -e 's/\(.*protocol.ftp.*\)/# \1/' ${PN}.conf
	fi
	sed -i -e 's/\(.*set protocol.ftp.use_epsv.*\)/# \1/' ${PN}.conf
	cd ${S}
	epatch ${FILESDIR}/${PN}-0.11.0-gcc4-inline.patch
	epatch ${FILESDIR}/${PN}-0.11.0-ruby.patch
	epatch ${FILESDIR}/${PN}-0.11.1-time.patch
	epatch ${FILESDIR}/${PN}-0.11.2-lua-5.patch

	if use lua && has_version ">=dev-lang/lua-5.1"; then
		epatch ${FILESDIR}/${PN}-0.11.2-lua-5.1.patch
	fi

	if use unicode ; then
		epatch ${FILESDIR}/elinks-0.10.1-utf_8_io-default.patch
	fi

	sed -i -e 's/-Werror//' configure*
}

src_compile() {
	# NOTE about GNUTSL SSL support (from the README -- 25/12/2002)
	# As GNUTLS is not yet 100% stable and its support in ELinks is not so well
	# tested yet, it's recommended for users to give a strong preference to OpenSSL whenever possible.
	local myconf=""

	# fix looking for make, in prefix we know that we have "make" which is a
	# good one
	sed -i -e "/for make in gnumake gmake make false; do/s/gnumake gmake//" \
		${S}/configure.in

	eautoreconf

	if use debug ; then
		myconf="--enable-debug"
	else
		myconf="--enable-fastmem"
	fi

	if use ssl ; then
		myconf="${myconf} --with-openssl"
	else
		myconf="${myconf} --without-openssl --without-gnutls"
	fi

	econf \
		--sysconfdir="${EPREFIX}"/etc/elinks \
		--enable-leds \
		--enable-88-colors \
		--enable-256-colors \
		--enable-html-highlight \
		$(use_with gpm) \
		$(use_with zlib) \
		$(use_with bzip2 bzlib) \
		$(use_with X x) \
		$(use_with lua) \
		$(use_with guile) \
		$(use_with perl) \
		$(use_with ruby) \
		$(use_with idn) \
		$(use_with javascript spidermonkey) \
		$(use_enable bittorrent) \
		$(use_enable nls) \
		$(use_enable ipv6) \
		$(use_enable ftp) \
		$(use_enable gopher) \
		$(use_enable nntp) \
		$(use_enable finger) \
		${myconf} || die

	emake || die "compile problem"
}

src_install() {
	make DESTDIR="${D}" install || die

	insopts -m 644 ; insinto /etc/elinks
	doins "${WORKDIR}"/elinks.conf
	newins contrib/keybind-full.conf keybind-full.sample
	newins contrib/keybind.conf keybind.conf.sample

	dodoc AUTHORS BUGS ChangeLog INSTALL NEWS README SITES THANKS TODO doc/*.*
	docinto contrib ; dodoc contrib/{README,colws.diff,elinks[-.]vim*}
	insinto /usr/share/doc/${PF}/contrib/lua ; doins contrib/lua/{*.lua,elinks-remote}
	insinto /usr/share/doc/${PF}/contrib/conv ; doins contrib/conv/*.*
	insinto /usr/share/doc/${PF}/contrib/guile ; doins contrib/guile/*.scm

	# Remove some conflicting files on OSX.  The files provided by OSX 10.4
	# are more or less the same.  -- Fabian Groffen (2005-06-30)
	rm -f "${ED}"/usr/share/locale/locale.alias "${ED}"/usr/lib/charset.alias
}

pkg_postinst() {
	einfo "This ebuild provides a default config for ELinks."
	einfo "Please check /etc/elinks/elinks.conf"
	einfo
	einfo "You may want to convert your html.cfg and links.cfg of"
	einfo "Links or older ELinks versions to the new ELinks elinks.conf"
	einfo "using /usr/share/doc/${PF}/contrib/conv/conf-links2elinks.pl"
	einfo
	einfo "Please have a look at /etc/elinks/keybind-full.sample and"
	einfo "/etc/elinks/keybind.conf.sample for some bindings examples."
	einfo
	einfo "You will have to set your TERM variable to 'xterm-256color'"
	einfo "to be able to use 256 colors in elinks."
	echo
}
