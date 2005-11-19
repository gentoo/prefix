# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/wget/wget-1.10.2.ebuild,v 1.8 2005/10/25 13:07:25 seemant Exp $

EAPI="prefix"

inherit eutils flag-o-matic

PATCHVER=0.1
DESCRIPTION="Network utility to retrieve files from the WWW"
HOMEPAGE="http://wget.sunsite.dk/"
SRC_URI="mirror://gentoo/${P}.tar.gz
	mirror://gnu/wget/${P}.tar.gz
	http://dev.gentoo.org/~seemant/distfiles/${P}-gentoo-${PATCHVER}.tar.bz2
	mirror://gentoo/${P}-gentoo-${PATCHVER}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm hppa ia64 m68k ~mips ppc ~ppc-macos ~ppc64 s390 sh sparc x86"
IUSE="build debug ipv6 nls socks5 ssl static"

RDEPEND="ssl? ( >=dev-libs/openssl-0.9.6b )
	socks5? ( net-proxy/dante )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	sys-devel/autoconf"

src_unpack() {
	unpack ${A}
	cd "${S}"
	local PATCHDIR=${WORKDIR}/patches
	EPATCH_SUFFIX="patch"
	EPATCH_MULTI_MSG="Applying Gentoo patches ..." epatch "${PATCHDIR}"/gentoo
	EPATCH_MULTI_MSG="Applying Mandrake patches ..." epatch "${PATCHDIR}"/mandrake
	autoconf || die "autoconf failed"
}

src_compile() {
	use static && append-ldflags -static
	econf \
		--sysconfdir=${PREFIX}/etc/wget \
		$(use_with ssl) $(use_enable ssl opie) $(use_enable ssl digest) \
		$(use_enable ipv6) \
		$(use_enable nls) \
		$(use_enable debug) \
		$(use_with socks5 socks) \
		|| die
	emake || die
}

src_install() {
	if use build ; then
		dobin "${S}"/src/wget || die "dobin"
		return 0
	fi

	make DESTDIR="${DEST}" install || die
	dodoc AUTHORS ChangeLog MAILING-LIST NEWS README TODO
	dodoc doc/sample.wgetrc

	if use ipv6 ; then
		ebegin "Adding a note about ipv6 in the config file"
		cat ${FILESDIR}/wgetrc-ipv6 >> ${D}/etc/wget/wgetrc
		eend $?
	fi

}
