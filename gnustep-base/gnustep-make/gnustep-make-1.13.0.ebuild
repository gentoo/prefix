# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnustep-base/gnustep-make/gnustep-make-1.13.0.ebuild,v 1.3 2007/03/18 01:33:13 genone Exp $

EAPI="prefix"

inherit gnustep

DESCRIPTION="GNUstep Makefile Package"

HOMEPAGE="http://www.gnustep.org"
SRC_URI="ftp://ftp.gnustep.org/pub/gnustep/core/${P}.tar.gz"
KEYWORDS="~amd64 ~ppc-macos ~x86"
SLOT="0"
LICENSE="GPL-2"

IUSE="${IUSE} doc non-flattened"
DEPEND="${GNUSTEP_CORE_DEPEND}
	>=sys-devel/make-3.75"
RDEPEND="${DEPEND}
	${DOC_RDEPEND}"

egnustep_install_domain "System"

pkg_setup() {
	gnustep_pkg_setup

	if [ "$(objc_available)" == "no" ]; then
		objc_not_available_info
		die "ObjC support not available"
	fi
}

src_compile() {
	cd ${S}

	econf \
		--prefix="${EPREFIX}"/usr/GNUstep \
		--with-tar="${EPREFIX}"/bin/tar \
		--with-local-root="${EPREFIX}"/usr/GNUstep/Local \
		--with-network-root="${EPREFIX}"/usr/GNUstep/Network \
		--with-system-root="${EPREFIX}"/usr/GNUstep/System \
		--with-user-root='~/GNUstep' \
		--with-config-file="${EPREFIX}"/etc/GNUstep/GNUstep.conf \
		--disable-importing-config-file \
		|| die "configure failed"

	egnustep_make
}

src_install() {
	. ${S}/GNUstep.sh

	local make_eval="GNUSTEP_USER_ROOT=${TMP} \
		GNUSTEP_DEFAULTS_ROOT=${TMP}/${__GS_USER_ROOT_POSTFIX} \
		GNUSTEP_INSTALLATION_DIR=${ED}/usr/GNUstep/System \
		-j1"

	use debug && make_eval="${make_eval} debug=yes"

	make ${make_eval} verbose=yes special_prefix="${D}" install \
		|| die "install has failed"

	if use doc ; then
		local docinstall="GNUSTEP_INSTALLATION_DIR=${ED}/usr/GNUstep/System"
		cd Documentation
		emake ${make_eval} all \
			|| die "doc make has failed"
		emake ${make_eval} ${docinstall} install \
			|| die "doc install has failed"
		cd ..
	fi

	dodir /etc/conf.d
	local prefix="\"${EPREFIX}\"/usr/GNUstep"
	echo "GNUSTEP_SYSTEM_ROOT=${prefix}/System" > ${ED}/etc/conf.d/gnustep.env
	echo "GNUSTEP_LOCAL_ROOT=${prefix}/Local" >> ${ED}/etc/conf.d/gnustep.env
	echo "GNUSTEP_NETWORK_ROOT=${prefix}/Network" >> ${ED}/etc/conf.d/gnustep.env
	echo "GNUSTEP_USER_ROOT='~/GNUstep'" >> ${ED}/etc/conf.d/gnustep.env

	insinto /etc/GNUstep
	doins ${S}/GNUstep.conf

	exeinto /etc/profile.d
	doexe ${FILESDIR}/gnustep.sh
	doexe ${FILESDIR}/gnustep.csh
}

