# Eclass for optional Java packages
#
# Copyright (c) 2004-2005, Thomas Matthijs <axxo@gentoo.org>
# Copyright (c) 2004-2005, Gentoo Foundation
#
# Licensed under the GNU General Public License, v2
#
# Major changes:
#    20070805: 
#       Removed phase hooks because Portage does proper env saving now.
#       <betelgeuse@gentoo.org>
#
# $Header: /var/cvsroot/gentoo-x86/eclass/java-pkg-opt-2.eclass,v 1.7 2007/08/05 08:24:30 betelgeuse Exp $

inherit java-utils-2

# ------------------------------------------------------------------------------
# @eclass-begin
# @eclass-summary Eclass for packages with optional Java support
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# @ebuild-variable JAVA_PKG_OPT_USE
#
# USE flag to control if optional Java stuff is build. Defaults to 'java'.
# ------------------------------------------------------------------------------
JAVA_PKG_OPT_USE=${JAVA_PKG_OPT_USE:-java}

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
DEPEND="${JAVA_PKG_OPT_USE}? ( ${JAVA_PKG_E_DEPEND} )"
RDEPEND="${DEPEND}"

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
IUSE="${JAVA_PKG_OPT_USE}"

EXPORT_FUNCTIONS pkg_setup

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
java-pkg-opt-2_pkg_setup() {
	use ${JAVA_PKG_OPT_USE} && java-pkg_init
}
