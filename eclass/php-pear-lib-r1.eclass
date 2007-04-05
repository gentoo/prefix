# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-pear-lib-r1.eclass,v 1.11 2007/03/22 20:12:56 chtekk Exp $
#
# Author: Luca Longinotti <chtekk@gentoo.org>
# Maintained by the PHP Team <php-bugs@gentoo.org>
#
# The php-pear-lib-r1 eclass provides means for an easy installation of PEAR
# based libraries, such as Creole, Jargon, Phing etc., while retaining
# the functionality to put the libraries into version-dependant directories.

inherit depend.php

EXPORT_FUNCTIONS src_install

DEPEND="dev-lang/php >=dev-php/PEAR-PEAR-1.4.6"
RDEPEND="${DEPEND}"

php-pear-lib-r1_src_install() {
	has_php

	# SNMP support
	addpredict /usr/share/snmp/mibs/.index
	addpredict /var/lib/net-snmp/
	addpredict /session_mm_cli0.sem

	case "${CATEGORY}" in
		dev-php)
			if has_version '=dev-lang/php-5*' ; then
				PHP_BIN="/usr/lib/php5/bin/php"
			else
				PHP_BIN="/usr/lib/php4/bin/php"
			fi ;;
		dev-php4) PHP_BIN="/usr/lib/php4/bin/php" ;;
		dev-php5) PHP_BIN="/usr/lib/php5/bin/php" ;;
		*) die "Version of PHP required by packages in category ${CATEGORY} unknown"
	esac

	cd "${S}"
	mv -f "${WORKDIR}/package.xml" "${S}"

	if has_version '>=dev-php/PEAR-PEAR-1.4.8' ; then
		pear -d php_bin="${PHP_BIN}" install --force --loose --nodeps --offline --packagingroot="${ED}" "${S}/package.xml" > /dev/null || die "Unable to install PEAR package"
	else
		pear -d php_bin="${PHP_BIN}" install --nodeps --packagingroot="${ED}" "${S}/package.xml" > /dev/null || die "Unable to install PEAR package"
	fi

	rm -Rf "${ED}/usr/share/php/.channels" \
	"${ED}/usr/share/php/.depdblock" \
	"${ED}/usr/share/php/.depdb" \
	"${ED}/usr/share/php/.filemap" \
	"${ED}/usr/share/php/.lock" \
	"${ED}/usr/share/php/.registry"

	# install to the correct phpX folder, if not specified
	# /usr/share/php will be kept, also sedding to substitute
	# the path, many files can specify it wrongly
	if [[ -n "${PHP_SHARED_CAT}" ]] && [[ "${PHP_SHARED_CAT}" != "php" ]] ; then
		mv -f "${ED}/usr/share/php" "${ED}/usr/share/${PHP_SHARED_CAT}" || die "Unable to move files"
		find "${ED}/" -type f -exec sed -e "s|/usr/share/php|/usr/share/${PHP_SHARED_CAT}|g" -i {} \; || die "Unable to change PHP path"
		einfo
		einfo "Installing to /usr/share/${PHP_SHARED_CAT} ..."
		einfo
	else
		einfo
		einfo "Installing to /usr/share/php ..."
		einfo
	fi
}
