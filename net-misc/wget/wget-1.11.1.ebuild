# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/wget/wget-1.11.1.ebuild,v 1.6 2008/05/07 20:54:13 maekke Exp $

EAPI="prefix"

inherit eutils flag-o-matic

DESCRIPTION="Network utility to retrieve files from the WWW"
HOMEPAGE="http://www.gnu.org/software/wget/"
SRC_URI="mirror://gnu/wget/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="debug ipv6 nls socks5 ssl static"

RDEPEND="ssl? ( >=dev-libs/openssl-0.9.6b )
	socks5? ( net-proxy/dante )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-1.11-linking.patch
	epatch "${FILESDIR}"/${PN}-1.11-no-solaris-md5.patch
	epatch "${FILESDIR}"/${P}-interix3.patch
}

src_compile() {
	# openssl-0.9.8 now builds with -pthread on the BSD's
	use elibc_FreeBSD && use ssl && append-ldflags -pthread

	[[ ${CHOST} == *-interix* ]] && append-flags -D_ALL_SOURCE

	use static && append-ldflags -static
	econf \
		$(use_with ssl) $(use_enable ssl opie) $(use_enable ssl digest) \
		$(use_enable ipv6) \
		$(use_enable nls) \
		$(use_enable debug) \
		$(use_with socks5 socks) \
		|| die
	emake || die
}

src_install() {
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog* MAILING-LIST NEWS README
	dodoc doc/sample.wgetrc

	use ipv6 && cat "${FILESDIR}"/wgetrc-ipv6 >> "${ED}"/etc/wgetrc

	sed -i \
		-e 's:/usr/local/etc:/etc:g' \
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
