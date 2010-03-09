# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/wget/wget-1.12-r1.ebuild,v 1.2 2010/02/14 00:43:08 vapier Exp $

EAPI="2"

inherit eutils flag-o-matic

DESCRIPTION="Network utility to retrieve files from the WWW"
HOMEPAGE="http://www.gnu.org/software/wget/"
SRC_URI="mirror://gnu/wget/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="debug idn ipv6 nls ntlm +ssl static"

RDEPEND="idn? ( net-dns/libidn )
	ssl? ( >=dev-libs/openssl-0.9.6b )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

pkg_setup() {
	if ! use ssl && use ntlm ; then
		elog "USE=ntlm requires USE=ssl, so disabling ntlm support due to USE=-ssl"
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-1.12-linking.patch
	epatch "${FILESDIR}"/${PN}-1.12-sni.patch #301312
	epatch "${FILESDIR}"/${P}-debug-tests.patch #286173

	epatch "${FILESDIR}"/${PN}-1.12-no-solaris-md5.patch
	epatch "${FILESDIR}"/${PN}-1.12-static-link-libz.patch
	epatch "${FILESDIR}"/${PN}-1.12-PATH_MAX.patch #293551
}

src_configure() {
	# openssl-0.9.8 now builds with -pthread on the BSD's
	use elibc_FreeBSD && use ssl && append-ldflags -pthread

	use static && append-ldflags -static
	econf \
		--disable-rpath \
		$(use_with ssl) $(use_enable ssl opie) $(use_enable ssl digest) \
		$(use_enable idn iri) \
		$(use_enable ipv6) \
		$(use_enable nls) \
		$(use ssl && use_enable ntlm) \
		$(use_enable debug)
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog* MAILING-LIST NEWS README
	dodoc doc/sample.wgetrc

	use ipv6 && cat "${FILESDIR}"/wgetrc-ipv6 >> "${ED}"/etc/wgetrc

	sed -i \
		-e "s:/usr/local/etc:${EPREFIX}/etc:g" \
		"${ED}"/etc/wgetrc \
		"${ED}"/usr/share/man/man1/wget.1 \
		"${ED}"/usr/share/info/wget.info
}

pkg_preinst() {
	ewarn "The /etc/wget/wgetrc file has been relocated to /etc/wgetrc"
	if [[ -e ${EROOT}/etc/wget/wgetrc ]] ; then
		if [[ -e ${EROOT}/etc/wgetrc ]] ; then
			ewarn "You have both /etc/wget/wgetrc and /etc/wgetrc ... you should delete the former"
		else
			einfo "Moving /etc/wget/wgetrc to /etc/wgetrc for you"
			mv "${EROOT}"/etc/wget/wgetrc "${EROOT}"/etc/wgetrc
			rmdir "${EROOT}"/etc/wget 2>/dev/null
		fi
	fi
}
