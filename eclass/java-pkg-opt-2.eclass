# Eclass for optional Java packages
#
# Copyright (c) 2004-2005, Thomas Matthijs <axxo@gentoo.org>
# Copyright (c) 2004-2005, Gentoo Foundation
#
# Licensed under the GNU General Public License, v2
#

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

# ------------------------------------------------------------------------------
# @note
#
# We need to initialize the environment in every function because Portage
# will source /etc/profile between phases and trample all over the env.
# This is accomplished by phase hooks, which is available with newer versions of
# portage.
# ------------------------------------------------------------------------------

pre_pkg_setup() {
	java-pkg-opt-2_pkg_setup
}

pre_src_unpack() {
	java-pkg-opt-2_pkg_setup
}

pre_src_compile() {
	java-pkg-opt-2_pkg_setup
}

pre_src_install() {
	java-pkg-opt-2_pkg_setup
}

pre_src_test() {
	java-pkg-opt-2_pkg_setup
}

pre_pkg_preinst() {
	java-pkg-opt-2_pkg_setup
}

pre_pkg_postinst() {
	java-pkg-opt-2_pkg_setup
}
