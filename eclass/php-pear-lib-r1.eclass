# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-pear-lib-r1.eclass,v 1.10 2007/03/05 01:50:47 chtekk Exp $
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

	case "${CATEGORY}" in
		dev-php)
			if has_version '=dev-lang/php-5*' ; then
				PHP_BIN="/usr/lib/php5/bin/php"
			else
				PHP_BIN="/usr/lib/php4/bin/php"
			fi ;;
		dev-php4) PHP_BIN="/usr/lib/php4/bin/php" ;;
		dev-php5) PHP_BIN="/usr/lib/php5/bin/php" ;;
		*) die "I don't know which version of PHP packages in ${CATEGORY} require"
	esac

	cd "${S}"
	mv "${WORKDIR}/package.xml" "${S}"

	if has_version '=dev-php/PEAR-PEAR-1.3*' ; then
		pear -d php_bin="${PHP_BIN}" install --nodeps --installroot="${D}" "${S}/package.xml" > /dev/null || die "Unable to install PEAR package"
	else
		if has_version '>=dev-php/PEAR-PEAR-1.4.8' ; then
			pear -d php_bin="${PHP_BIN}" install --force --loose --nodeps --offline --packagingroot="${D}" "${S}/package.xml" > /dev/null || die "Unable to install PEAR package"
		else
			pear -d php_bin="${PHP_BIN}" install --nodeps --packagingroot="${D}" "${S}/package.xml" > /dev/null || die "Unable to install PEAR package"
		fi
	fi

	rm -rf "${D}/usr/share/php/.channels" \
	"${D}/usr/share/php/.depdblock" \
	"${D}/usr/share/php/.depdb" \
	"${D}/usr/share/php/.filemap" \
	"${D}/usr/share/php/.lock" \
	"${D}/usr/share/php/.registry"

	# install to the correct phpX folder, if not specified
	# /usr/share/php will be kept, also sedding to substitute
	# the path, many files can specify it wrongly
	if [ -n "${PHP_SHARED_CAT}" ] && [ "${PHP_SHARED_CAT}" != "php" ] ; then
		mv -f "${D}/usr/share/php" "${D}/usr/share/${PHP_SHARED_CAT}" || die "Unable to move files"
		find "${D}/" -type f -exec sed -e "s|/usr/share/php|/usr/share/${PHP_SHARED_CAT}|g" -i {} \; || die "Unable to change PHP path"
		einfo
		einfo "Installing to /usr/share/${PHP_SHARED_CAT} ..."
		einfo
	else
		einfo
		einfo "Installing to /usr/share/php ..."
		einfo
	fi
}
