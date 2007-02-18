# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnustep-base/gnustep-make/gnustep-make-1.13.0.ebuild,v 1.1 2006/09/03 15:05:05 grobian Exp $

EAPI="prefix"

inherit gnustep

DESCRIPTION="GNUstep Makefile Package"

HOMEPAGE="http://www.gnustep.org"
SRC_URI="ftp://ftp.gnustep.org/pub/gnustep/core/${P}.tar.gz"
KEYWORDS="~amd64 ~ppc-macos ~x86"
SLOT="0"
LICENSE="GPL-2"

IUSE="${IUSE} doc non-flattened layout-osx-like layout-from-conf-file"
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

	if use layout-from-conf-file && use layout-osx-like ; then
		eerror "layout-from-conf-file and layout-osx-like are mutually exclusive use flags."
		die "USE flag misconfiguration -- please correct"
	fi

	if use layout-from-conf-file || use layout-osx-like ; then
		ewarn "USE layout-from-conf-file || layout-osx-like"
		ewarn "Utilizing these USE flags allows one to install files in non standard"
		ewarn "  locations vis a vis the Linux FHS -- please fully comprehend what you"
		ewarn "  are doing when setting this USE flag."
	fi

	if use layout-from-conf-file; then
		if [ ! -f "${EROOT}"/etc/conf.d/gnustep.env ]; then
			eerror "There is no /etc/conf.d/gnustep.env file!"
			eerror "Did you read the USE flag description?"
			die "USE flag misconfiguration -- please correct"
		else
			unset GNUSTEP_SYSTEM_ROOT
			unset GNUSTEP_LOCAL_ROOT
			unset GNUSTEP_NETWORK_ROOT
			unset GNUSTEP_USER_ROOT
			. "${EROOT}"/etc/conf.d/gnustep.env
			if [ -z "${GNUSTEP_SYSTEM_ROOT}" ] || [ "/" != "${GNUSTEP_SYSTEM_ROOT:0:1}" ]; then
				eerror "GNUSTEP_SYSTEM_ROOT is missing or misconfigured in /etc/conf.d/gnustep.env"
				eerror "GNUSTEP_SYSTEM_ROOT=${GNUSTEP_SYSTEM_ROOT}"
				die "USE flag misconfiguration -- please correct"
			fi
			if [ "/System" != ${GNUSTEP_SYSTEM_ROOT:$((${#GNUSTEP_SYSTEM_ROOT}-7)):7} ]; then
				eerror "GNUSTEP_SYSTEM_ROOT must end with \"System\" -- read the USE flag directions!!!"
				die "USE flag misconfiguration -- please correct"
			fi
			if [ "${GNUSTEP_LOCAL_ROOT}" ] && [ "/" != "${GNUSTEP_LOCAL_ROOT:0:1}" ]; then
				eerror "GNUSTEP_LOCAL_ROOT is misconfigured in /etc/conf.d/gnustep.env"
				eerror "GNUSTEP_LOCAL_ROOT=${GNUSTEP_LOCAL_ROOT}"
				die "USE flag misconfiguration -- please correct"
			elif [ -z "${GNUSTEP_LOCAL_ROOT}" ]; then
				GNUSTEP_LOCAL_ROOT="$(dirname ${GNUSTEP_SYSTEM_ROOT})/Local"
			fi
			if [ "${GNUSTEP_NETWORK_ROOT}" ] && [ "/" != "${GNUSTEP_NETWORK_ROOT:0:1}" ]; then
				eerror "GNUSTEP_NETWORK_ROOT is misconfigured in /etc/conf.d/gnustep.env"
				eerror "GNUSTEP_NETWORK_ROOT=${GNUSTEP_NETWORK_ROOT}"
				die "USE flag misconfiguration -- please correct"
			elif [ -z "${GNUSTEP_NETWORK_ROOT}" ]; then
				GNUSTEP_NETWORK_ROOT="$(dirname ${GNUSTEP_SYSTEM_ROOT})/Network"
			fi
			if [ "${GNUSTEP_USER_ROOT}" ] && [ '~' != "${GNUSTEP_USER_ROOT:0:1}" ]; then
				eerror "GNUSTEP_USER_ROOT is misconfigured in /etc/conf.d/gnustep.env"
				eerror "GNUSTEP_USER_ROOT=${GNUSTEP_USER_ROOT}"
				die "USE flag misconfiguration -- please correct"
			elif [ -z "${GNUSTEP_USER_ROOT}" ]; then
				GNUSTEP_USER_ROOT='~/GNUstep'
			fi

			egnustep_prefix "$(dirname ${GNUSTEP_SYSTEM_ROOT})"
			egnustep_system_root "${GNUSTEP_SYSTEM_ROOT}"
			egnustep_local_root "${GNUSTEP_LOCAL_ROOT}"
			egnustep_network_root "${GNUSTEP_NETWORK_ROOT}"
			egnustep_user_root "${GNUSTEP_USER_ROOT}"
		fi
	elif use layout-osx-like; then
		egnustep_prefix "/"
		egnustep_system_root "/System"
		egnustep_local_root "/"
		egnustep_network_root "/Network"
		egnustep_user_root '~'
	else
		# setup defaults here
		egnustep_prefix "/usr/GNUstep"
		egnustep_system_root "/usr/GNUstep/System"
		egnustep_local_root "/usr/GNUstep/Local"
		egnustep_network_root "/usr/GNUstep/Network"
		egnustep_user_root '~/GNUstep'
	fi

	einfo "GNUstep installation will be laid out as follows:"
	einfo "\tGNUSTEP_SYSTEM_ROOT=${EPREFIX}`egnustep_system_root`"
	einfo "\tGNUSTEP_LOCAL_ROOT=${EPREFIX}`egnustep_local_root`"
	einfo "\tGNUSTEP_NETWORK_ROOT=${EPREFIX}`egnustep_network_root`"
	einfo "\tGNUSTEP_USER_ROOT=`egnustep_user_root`"
}

src_compile() {
	cd ${S}

	# gnustep-make ./configure : "prefix" here is going to be where
	#  "System" is installed -- other correct paths should be set
	#  by econf
	local myconf
	myconf="--prefix=${EPREFIX}`egnustep_prefix`"
	use non-flattened && myconf="$myconf --disable-flattened --enable-multi-platform"
	myconf="$myconf --with-tar=${EPREFIX}/bin/tar"
	myconf="$myconf --with-local-root=${EPREFIX}`egnustep_local_root`"
	myconf="$myconf --with-network-root=${EPREFIX}`egnustep_network_root`"
	myconf="$myconf --with-user-root=`egnustep_user_root`"
	myconf="$myconf --with-config-file=${EPREFIX}/etc/GNUstep/GNUstep.conf"
	econf $myconf || die "configure failed"

	egnustep_make
}

src_install() {
	. ${S}/GNUstep.sh

	local make_eval="INSTALL_ROOT=${ED} \
		GNUSTEP_SYSTEM_ROOT=${ED}$(egnustep_system_root) \
		GNUSTEP_NETWORK_ROOT=${ED}$(egnustep_network_root) \
		GNUSTEP_LOCAL_ROOT=${ED}$(egnustep_local_root) \
		GNUSTEP_MAKEFILES=${ED}$(egnustep_system_root)/Library/Makefiles \
		GNUSTEP_USER_ROOT=${TMP} \
		GNUSTEP_DEFAULTS_ROOT=${TMP}/${__GS_USER_ROOT_POSTFIX} \
		-j1"

	local docinstall="GNUSTEP_INSTALLATION_DIR=${ED}$(egnustep_system_root)"

	make_eval="${make_eval} GNUSTEP_INSTALLATION_DIR=${ED}$(egnustep_system_root)"

	use debug && make_eval="${make_eval} debug=yes"
	use verbose && make_eval="${make_eval} verbose=yes"

	make ${make_eval} special_prefix=${D} install \
		|| die "install has failed"

	if use doc ; then
		cd Documentation
		emake ${make_eval} all \
			|| die "doc make has failed"
		emake ${make_eval} ${docinstall} install \
			|| die "doc install has failed"
		cd ..
	fi

	dodir /etc/conf.d
	echo "GNUSTEP_SYSTEM_ROOT=${EPREFIX}$(egnustep_system_root)" > ${ED}/etc/conf.d/gnustep.env
	echo "GNUSTEP_LOCAL_ROOT=${EPREFIX}$(egnustep_local_root)" >> ${ED}/etc/conf.d/gnustep.env
	echo "GNUSTEP_NETWORK_ROOT=${EPREFIX}$(egnustep_network_root)" >> ${ED}/etc/conf.d/gnustep.env
	echo "GNUSTEP_USER_ROOT='$(egnustep_user_root)'" >> ${ED}/etc/conf.d/gnustep.env

	insinto /etc/GNUstep
	doins ${S}/GNUstep.conf

	exeinto /etc/profile.d
	doexe ${FILESDIR}/gnustep.sh
	doexe ${FILESDIR}/gnustep.csh
}

