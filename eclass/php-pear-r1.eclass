# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-pear-r1.eclass,v 1.15 2007/03/22 20:12:56 chtekk Exp $
#
# Author: Tal Peer <coredumb@gentoo.org>
# Author: Luca Longinotti <chtekk@gentoo.org>
# Maintained by the PHP Team <php-bugs@gentoo.org>
#
# The php-pear-r1 eclass provides means for an easy installation of PEAR
# packages, see http://pear.php.net/

# Note that this eclass doesn't handle PEAR packages' dependencies on
# purpose, please use (R)DEPEND to define them correctly!

EXPORT_FUNCTIONS src_install

DEPEND="dev-lang/php >=dev-php/PEAR-PEAR-1.4.6"
RDEPEND="${DEPEND}"

# Set this if the the PEAR package name is different than the one in
# Portage (generally shouldn't be the case).
[[ -z "${PHP_PEAR_PKG_NAME}" ]] && PHP_PEAR_PKG_NAME="${PN/PEAR-/}"

fix_PEAR_PV() {
	tmp="${PV}"
	tmp="${tmp/_/}"
	tmp="${tmp/rc/RC}"
	tmp="${tmp/beta/b}"
	PEAR_PV="${tmp}"
}

PEAR_PV=""
fix_PEAR_PV
PEAR_PN="${PHP_PEAR_PKG_NAME}-${PEAR_PV}"

[[ -z "${SRC_URI}" ]] && SRC_URI="http://pear.php.net/get/${PEAR_PN}.tgz"
[[ -z "${HOMEPAGE}" ]] && HOMEPAGE="http://pear.php.net/${PHP_PEAR_PKG_NAME}"

S="${WORKDIR}/${PEAR_PN}"

php-pear-r1_src_install() {
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
}
