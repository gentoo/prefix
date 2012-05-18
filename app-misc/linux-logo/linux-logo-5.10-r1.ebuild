# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/linux-logo/linux-logo-5.10-r1.ebuild,v 1.6 2011/07/09 09:03:27 xarthisius Exp $

EAPI="2"

inherit eutils toolchain-funcs

MY_P=${PN/-/_}-${PV}
S=${WORKDIR}/${MY_P}
DESCRIPTION="A utility that displays an ANSI/ASCII logo and some system information"
HOMEPAGE="http://www.deater.net/weave/vmwprod/linux_logo/"
SRC_URI="http://www.deater.net/weave/vmwprod/linux_logo/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux"
IUSE="nls"

RDEPEND="nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"
	echo "./logos/gentoo.logo" >> logo_config
	echo "./logos/gentoo2.logo" >> logo_config
	echo "./logos/banner-simplified.logo" >> logo_config
	echo "./logos/banner.logo" >> logo_config
	echo "./logos/classic-no_periods.logo" >> logo_config
	echo "./logos/classic-no_periods_or_chars.logo" >> logo_config
	echo "./logos/classic.logo" >> logo_config
	cp "${FILESDIR}"/gentoo{,2}.logo "${S}"/logos/
	echo "NAME gentoo" >> "${S}"/logos/gentoo.logo
}

src_prepare() {
	epatch "${FILESDIR}"/linux_logo-5.10-makefile-tabs.patch

	if [[ ${CHOST} == *-interix* ]]; then
		epatch "${FILESDIR}"/${PN}-5.06-interix.patch
		epatch "${FILESDIR}"/${PN}-5.06-no-i18n.patch
	fi
}

src_compile() {
	ARCH="" "${BASH}" ./configure --prefix="${ED}"/usr || die
	emake CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}" CC="$(tc-getCC)" || die
}

src_install() {
	make install || die

	dodoc BUGS README README.CUSTOM_LOGOS TODO USAGE LINUX_LOGO.FAQ

	cp "${FILESDIR}"/${PN}.conf "${WORKDIR}"
	sed -i -e 's/-L 4 -f -u/-f -u/' "${WORKDIR}"/${PN}.conf

	newinitd "${FILESDIR}"/${PN}.initscript ${PN}
	newconfd "${WORKDIR}"/${PN}.conf ${PN}
}

pkg_postinst() {
	echo
	elog "Linux_logo ebuild for Gentoo comes with two Gentoo logos."
	elog ""
	elog "To display the first Gentoo logo type: linux_logo -L gentoo"
	elog "To display the second Gentoo logo type: linux_logo -L gentoo-alt"
	elog "To display all the logos available type: linux_logo -L list."
	elog ""
	elog "To start linux_logo on boot, please type:"
	elog "   rc-update add linux-logo default"
	elog "which uses the settings found in"
	elog "   /etc/conf.d/linux-logo"
	echo
}
