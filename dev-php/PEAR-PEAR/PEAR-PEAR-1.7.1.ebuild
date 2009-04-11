# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-php/PEAR-PEAR/PEAR-PEAR-1.7.1.ebuild,v 1.2 2008/03/17 17:18:17 mr_bones_ Exp $

inherit depend.php

ARCHIVE_TAR="1.3.2"
CONSOLE_GETOPT="1.2.3"
STRUCTURES_GRAPH="1.0.2"
XML_RPC="1.5.1"
PEAR="${PV}"

KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"

DESCRIPTION="PEAR Base System (PEAR, Archive_Tar, Console_Getopt, Structures_Graph, XML_RPC)."
HOMEPAGE="http://pear.php.net/"
SRC_URI="http://pear.php.net/get/Archive_Tar-${ARCHIVE_TAR}.tgz
		http://pear.php.net/get/Console_Getopt-${CONSOLE_GETOPT}.tgz
		http://pear.php.net/get/Structures_Graph-${STRUCTURES_GRAPH}.tgz
		http://pear.php.net/get/XML_RPC-${XML_RPC}.tgz
		http://pear.php.net/get/PEAR-${PEAR}.tgz"
LICENSE="LGPL-2.1 PHP-2.02 PHP-3 PHP-3.01 MIT"
SLOT="0"
IUSE=""

DEPEND="dev-lang/php"
RDEPEND="${DEPEND}"

S=${WORKDIR}

pkg_setup() {
	has_php

	# we check that PHP was compiled with the correct USE flags
	if [[ ${PHP_VERSION} == "4" ]] ; then
		require_php_with_use cli pcre expat zlib
	else
		require_php_with_use cli pcre xml zlib
	fi

	[[ -z "${PEAR_CACHEDIR}" ]] && PEAR_CACHEDIR="${EPREFIX}/var/cache/pear"
	[[ -z "${PEAR_DOWNLOADDIR}" ]] && PEAR_DOWNLOADDIR="${EPREFIX}/var/tmp/pear"
	[[ -z "${PEAR_TEMPDIR}" ]] && PEAR_TEMPDIR="${EPREFIX}/tmp"

	elog
	elog "cache_dir is set to: ${PEAR_CACHEDIR}"
	elog "download_dir is set to: ${PEAR_DOWNLOADDIR}"
	elog "temp_dir is set to: ${PEAR_TEMPDIR}"
	elog
	elog "If you want to change the above values, you need to set"
	elog "PEAR_CACHEDIR, PEAR_DOWNLOADDIR and PEAR_TEMPDIR variable(s)"
	elog "accordingly in /etc/make.conf and re-emerge ${PN}."
	elog
}

src_install() {
	# Prevent SNMP related sandbox violoation.
	addpredict /usr/share/snmp/mibs/.index
	addpredict /var/lib/net-snmp/

	# install PEAR package
	cd "${S}"/PEAR-${PEAR}

	insinto /usr/share/php
	doins -r PEAR/
	doins -r OS/
	doins PEAR.php System.php
	doins scripts/pearcmd.php
	doins scripts/peclcmd.php

	newbin scripts/pear.sh pear
	newbin scripts/peardev.sh peardev
	newbin scripts/pecl.sh pecl

	# install Archive_Tar package
	cd "${S}"/Archive_Tar-${ARCHIVE_TAR}
	insinto /usr/share/php
	doins -r Archive/

	# install Console_Getopt package.
	cd "${S}"/Console_Getopt-${CONSOLE_GETOPT}
	insinto /usr/share/php
	doins -r Console/

	# install Structures_Graph package
	cd "${S}"/Structures_Graph-${STRUCTURES_GRAPH}
	insinto /usr/share/php
	doins -r Structures/

	# install XML_RPC package
	cd "${S}"/XML_RPC-${XML_RPC}
	insinto /usr/share/php/XML
	doins RPC.php
	insinto /usr/share/php/XML/RPC
	doins Dump.php Server.php

	# adjust some scripts for current version
	for i in pearcmd.php peclcmd.php ; do
		dosed "s:@pear_version@:${PEAR}:g" /usr/share/php/${i}
	done

	for i in pear peardev pecl ; do
		dosed "s:@php_bin@:${PHPCLI}:g" /usr/bin/${i}
		dosed "s:@bin_dir@:${EPREFIX}/usr/bin:g" /usr/bin/${i}
		dosed "s:@php_dir@:${EPREFIX}/usr/share/php:g" /usr/bin/${i}
	done
	dosed "s:-d output_buffering=1:-d output_buffering=1 -d memory_limit=32M:g" /usr/bin/pear

	dosed "s:@package_version@:${PEAR}:g" /usr/share/php/PEAR/Command/Package.php
	dosed "s:@PEAR-VER@:${PEAR}:g" /usr/share/php/PEAR/Dependency2.php
	dosed "s:@PEAR-VER@:${PEAR}:g" /usr/share/php/PEAR/PackageFile/Parser/v1.php
	dosed "s:@PEAR-VER@:${PEAR}:g" /usr/share/php/PEAR/PackageFile/Parser/v2.php

	# finalize install
	insinto /etc
	newins "${FILESDIR}"/pear.conf-r1 pear.conf
	dosed "s|s:PHPCLILEN:\"PHPCLI\"|s:${#PHPCLI}:\"${PHPCLI}\"|g" /etc/pear.conf
	dosed "s|s:CACHEDIRLEN:\"CACHEDIR\"|s:${#PEAR_CACHEDIR}:\"${PEAR_CACHEDIR}\"|g" /etc/pear.conf
	dosed "s|s:DOWNLOADDIRLEN:\"DOWNLOADDIR\"|s:${#PEAR_DOWNLOADDIR}:\"${PEAR_DOWNLOADDIR}\"|g" /etc/pear.conf
	dosed "s|s:TEMPDIRLEN:\"TEMPDIR\"|s:${#PEAR_TEMPDIR}:\"${PEAR_TEMPDIR}\"|g" /etc/pear.conf

    # Change the paths for eprefix!
    dosed "s|s:19:\"/usr/share/php/docs\"|s:$(( ${#EPREFIX}+19 )):\"${EPREFIX}/usr/share/php/docs\"|g" /etc/pear.conf
    dosed "s|s:19:\"/usr/share/php/data\"|s:$(( ${#EPREFIX}+19 )):\"${EPREFIX}/usr/share/php/data\"|g" /etc/pear.conf
    dosed "s|s:20:\"/usr/share/php/tests\"|s:$(( ${#EPREFIX}+20 )):\"${EPREFIX}/usr/share/php/tests\"|g" /etc/pear.conf
    dosed "s|s:14:\"/usr/share/php\"|s:$(( ${#EPREFIX}+14 )):\"${EPREFIX}/usr/share/php\"|g" /etc/pear.conf
    dosed "s|s:8:\"/usr/bin\"|s:$(( ${#EPREFIX}+8 )):\"${EPREFIX}/usr/bin\"|g" /etc/pear.conf

	[[ "${PEAR_TEMPDIR}" != "/tmp" ]] && keepdir "${PEAR_TEMPDIR#${EPREFIX}}"
	keepdir "${PEAR_CACHEDIR#${EPREFIX}}"
	diropts -m1777
	keepdir "${PEAR_DOWNLOADDIR#${EPREFIX}}"
}

pkg_preinst() {
	rm -f "${EROOT}/etc/pear.conf"
}

pkg_postinst() {
	pear clear-cache

	# Update PEAR/PECL channels as needed, add new ones to the list if needed
	local pearchans="pear.php.net pecl.php.net components.ez.no pear.phpdb.org pear.phing.info
			pear.symfony-project.com pear.phpunit.de pear.php-baustelle.de pear.zeronotice.org
			pear.phpontrax.com pear.agavi.org"

	for chan in ${pearchans} ; do
		pear channel-discover ${chan}
		pear channel-update ${chan}
	done
}
