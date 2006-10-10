# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-pear-r1.eclass,v 1.13 2006/03/10 10:47:49 sebastian Exp $
#
# Author: Tal Peer <coredumb@gentoo.org>
# Maintained by the PHP Herd <php-bugs@gentoo.org>
#
# The php-pear-r1 eclass provides means for an easy installation of PEAR
# packages, see http://pear.php.net

# Note that this eclass doesn't handle PEAR packages' dependencies on
# purpose, please use (R)DEPEND to define them.

EXPORT_FUNCTIONS src_install

# Set this is the the package name on PEAR is different than the one in
# portage (generally shouldn't be the case).
[ -z "${PHP_PEAR_PKG_NAME}" ] && PHP_PEAR_PKG_NAME=${PN/PEAR-/}

# We must depend on the base package as we need it to do
# install tasks (it provides the pear binary).
DEPEND="${DEPEND} dev-lang/php >=dev-php/PEAR-PEAR-1.3.6"
RDEPEND="${RDEPEND} ${DEPEND}"

fix_PEAR_PV() {
	tmp=${PV}
	tmp=${tmp/_/}
	tmp=${tmp/rc/RC}
	tmp=${tmp/beta/b}
	PEAR_PV=${tmp}
}

PEAR_PV=""
fix_PEAR_PV
PEAR_PN=${PHP_PEAR_PKG_NAME}-${PEAR_PV}

[ -z "${SRC_URI}" ] && SRC_URI="http://pear.php.net/get/${PEAR_PN}.tgz"
[ -z "${HOMEPAGE}" ] && HOMEPAGE="http://pear.php.net/${PHP_PEAR_PKG_NAME}"

S="${WORKDIR}/${PEAR_PN}"

php-pear-r1_src_install() {
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
}
