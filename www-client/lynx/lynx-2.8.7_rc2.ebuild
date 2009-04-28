# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/www-client/lynx/lynx-2.8.7_rc2.ebuild,v 1.2 2009/04/27 17:14:14 mr_bones_ Exp $

EAPI=2

inherit eutils versionator

# VERSIONING SCHEME TRANSLATION
# Upstream	:	Gentoo
# rel.		:	_p
# pre.		:	_rc
# dev.		:	_pre

if [[ "${PV/_p[0-9]}" != "${PV}" ]]
then
	MY_P="${PN}${PV/_p/rel.}"

elif [[ "${PV/_rc[0-9]}" != "${PV}" ]]
then
	MY_P="${PN}${PV/_rc/pre.}"

elif [[ "${PV/_pre[0-9]}" != "${PV}" ]]
then
	MY_P="${PN}${PV/_pre/dev.}"

fi

DESCRIPTION="An excellent console-based web browser with ssl support"
HOMEPAGE="http://lynx.isc.org/"
SRC_URI="http://lynx.isc.org/current/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="bzip2 cjk gnutls ipv6 nls openssl unicode"

RDEPEND="sys-libs/ncurses[unicode?]
	sys-libs/zlib
	nls? ( virtual/libintl )
	openssl? ( >=dev-libs/openssl-0.9.8 )
	!openssl? (
		gnutls? ( >=net-libs/gnutls-2.6.4 )
	)
	bzip2? ( app-arch/bzip2 )"

DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

S="${WORKDIR}/${PN}$(replace_all_version_separators - $(get_version_component_range 1-3))"

pkg_setup() {
	if use openssl
	then
		if use gnutls
		then
			elog "Both openssl and gnutls use-flags specified. Openssl will be used."
		fi
	else
		if ! use gnutls
		then
			elog "No SSL library selected, you will not be able to access secure websites."
		fi
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-2.8.6-darwin7.patch
	epatch "${FILESDIR}"/${PN}-2.8.6-mint.patch
}

src_configure() {
	econf \
		--enable-cgi-links \
		--enable-persistent-cookies \
		--enable-prettysrc \
		--enable-nsl-fork \
		--enable-file-upload \
		--enable-read-eta \
		--enable-color-style \
		--enable-scrollbar \
		--enable-included-msgs \
		--with-zlib \
		$(use_enable nls) \
		$(use_enable ipv6) \
		$(use_enable cjk) \
		$(use_enable unicode japanese-utf8) \
		$(use_with openssl ssl) \
		$(use_with gnutls) \
		$(use_with bzip2 bzlib) \
		$(use unicode && printf '%s' '--with-screen=ncursesw')
}

src_install() {
	make install DESTDIR="${D}" || die

	sed -i -e "s|^HELPFILE.*$|HELPFILE:file://localhost/usr/share/doc/${PF}/lynx_help/lynx_help_main.html|" \
			"${ED}"/etc/lynx.cfg || die "lynx.cfg not found"
	if use unicode
	then
		sed -i -e '/^#CHARACTER_SET:/ c\CHARACTER_SET:utf-8' \
				"${ED}"/etc/lynx.cfg || die "lynx.cfg not found"
	fi
	dodoc CHANGES COPYHEADER PROBLEMS README
	docinto docs
	dodoc docs/*
	docinto lynx_help
	dodoc lynx_help/*.txt
	dohtml -r lynx_help/*
}
