# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/php-ezc.eclass,v 1.3 2007/08/31 09:40:33 jokey Exp $
#
# Maintained by the PHP Team <php-bugs@gentoo.org>
#
# The php-ezc eclass provides means for an easy installation
# of the eZ components, see http://ez.no/products/ez_components

inherit php-pear-r1

EZC_PKG_NAME="${PN/ezc-/}"

fix_EZC_PV() {
	tmp="${PV}"
	tmp="${tmp/_/}"
	tmp="${tmp/rc/RC}"
	tmp="${tmp/beta/b}"
	EZC_PV="${tmp}"
}

# set EZC_PV in ebuilds if the PV mangling of beta/rc versions breaks SRC_URI
[[ -z "${EZC_PV}" ]] && fix_EZC_PV

EZC_PN="${EZC_PKG_NAME}-${EZC_PV}"

S="${WORKDIR}/${EZC_PN}"

DEPEND=">=dev-lang/php-5.1.2
		>=dev-php/PEAR-PEAR-1.4.6"

RDEPEND="${DEPEND}
		dev-php5/ezc-Base"

SRC_URI="http://components.ez.no/get/${EZC_PN}.tgz"
HOMEPAGE="http://ez.no/products/ez_components"
LICENSE="BSD"
