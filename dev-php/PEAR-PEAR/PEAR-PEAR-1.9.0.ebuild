# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-php/PEAR-PEAR/PEAR-PEAR-1.9.0.ebuild,v 1.2 2010/02/16 04:16:42 beandog Exp $

inherit depend.php

PEAR="${PV}"

KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"

DESCRIPTION="PEAR Base System"
HOMEPAGE="http://pear.php.net/package/PEAR"
SRC_URI="http://pear.php.net/get/PEAR-${PEAR}.tgz"
LICENSE="MIT"
SLOT="0"
IUSE=""

DEPEND="dev-lang/php"

S="${WORKDIR}"

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
	doins PEAR.php PEAR5.php System.php
	doins scripts/pearcmd.php
	doins scripts/peclcmd.php

	newbin scripts/pear.sh pear
	newbin scripts/peardev.sh peardev
	newbin scripts/pecl.sh pecl

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
