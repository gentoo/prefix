# Eclass for Java packages
#
# Copyright (c) 2004-2005, Thomas Matthijs <axxo@gentoo.org>
# Copyright (c) 2004-2005, Gentoo Foundation
#
# Licensed under the GNU General Public License, v2
#
# $Header: /var/cvsroot/gentoo-x86/eclass/java-pkg-2.eclass,v 1.8 2006/12/18 10:18:56 betelgeuse Exp $

inherit java-utils-2

# -----------------------------------------------------------------------------
# @eclass-begin
# @eclass-summary Eclass for Java Packages
#
# This eclass should be inherited for pure Java packages, or by packages which
# need to use Java.
# -----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# @depend
#
# Java packages need java-config, and a fairly new release of Portage.
#
# JAVA_PKG_E_DEPEND is defined in java-utils.eclass.
# ------------------------------------------------------------------------------
DEPEND="${JAVA_PKG_E_DEPEND}"

# ------------------------------------------------------------------------------
# @rdepend
#
# Nothing special for RDEPEND... just the same as DEPEND.
# ------------------------------------------------------------------------------
RDEPEND="${DEPEND}"

EXPORT_FUNCTIONS pkg_setup src_compile

# ------------------------------------------------------------------------------
# @eclass-pkg_setup
#
# pkg_setup initializes the Java environment
# ------------------------------------------------------------------------------
java-pkg-2_pkg_setup() {
	java-pkg_init
	java-pkg_ensure-test
}

# ------------------------------------------------------------------------------
# @eclass-src_compile
#
# Default src_compile for java packages
# variables:
# EANT_BUILD_XML - controls the location of the build.xml (default: ./build.xml)
# EANT_BUILD_TARGET - the ant target/targets to execute (default: jar)
# EANT_DOC_TARGET - the target to build extra docs under the doc use flag
#                   (default: the one provided by use_doc in
#                   java-utils-2.eclass)
# ------------------------------------------------------------------------------
java-pkg-2_src_compile() {
	if [[ -e "${EANT_BUILD_XML:=build.xml}" ]]; then
		local antflags="${EANT_BUILD_TARGET:=jar}"
		hasq doc ${IUSE} && antflags="${antflags} $(use_doc ${EANT_DOC_TARGET})"
		eant ${antflags} -f "${EANT_BUILD_XML}"
	else
		echo "${FUNCNAME}: No build.xml found so nothing to do."
	fi
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
	java-pkg-2_pkg_setup
}

pre_src_unpack() {
	java-pkg-2_pkg_setup
}

pre_src_compile() {
	java-pkg-2_pkg_setup
}

pre_src_install() {
	java-pkg-2_pkg_setup
}

pre_src_test() {
	java-pkg-2_pkg_setup
}

pre_pkg_preinst() {
	java-pkg-2_pkg_setup
}

pre_pkg_postinst() {
	java-pkg-2_pkg_setup
}

# ------------------------------------------------------------------------------
# @eclass-end
# ------------------------------------------------------------------------------
