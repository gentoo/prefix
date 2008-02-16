# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/texlive-module.eclass,v 1.8 2008/02/14 09:02:11 aballier Exp $

# @ECLASS: texlive-module.eclass
# @MAINTAINER:
# tex@gentoo.org
#
# Original Author: Alexis Ballier <aballier@gentoo.org>
# @BLURB: Provide generic install functions so that modular texlive's texmf ebuild will only have to inherit this eclass
# @DESCRIPTION: 
# Purpose: Provide generic install functions so that modular texlive's texmf ebuilds will
# only have to inherit this eclass.
# Ebuilds have to provide TEXLIVE_MODULE_CONTENTS variable that contains the list
# of packages that it will install. (See below)
#
# What is assumed is that it unpacks texmf and texmf-dist directories to
# ${WORKDIR}.
#
# It inherits texlive-common

# @ECLASS-VARIABLE: TEXLIVE_MODULE_CONTENTS
# @DESCRIPTION:
# The list of packages that will be installed. This variable will be expanded to
# SRC_URI:
#
# foo -> texlive-module-foo-${PV}.zip

inherit texlive-common

HOMEPAGE="http://www.tug.org/texlive/"

for i in ${TEXLIVE_MODULE_CONTENTS}; do
	SRC_URI="${SRC_URI} mirror://gentoo/texlive-module-${i}-${PV}.zip"
done

COMMON_DEPEND=">=app-text/texlive-core-${PV}
	${TEXLIVE_MODULES_DEPS}"

DEPEND="${COMMON_DEPEND}
	app-arch/unzip"

RDEPEND="${COMMON_DEPEND}"

IUSE="doc"

S="${WORKDIR}"

# @FUNCTION: texlive-module_src_compile
# @DESCRIPTION:
# exported function:
# Will look for format.foo.cnf and build foo format files using fmtutil
# (provided by texlive-core). The compiled format files will be sent to
# texmf-var/web2c, like fmtutil defaults to but with some trick to stay in the
# sandbox
# The next step is to generate config files that are to be installed in
# /etc/texmf; texmf-update script will take care of merging the different config
# files for different packages in a single one used by the whole tex installation.

texlive-module_src_compile() {
	# Build format files
	for i in texmf/fmtutil/format*.cnf; do
		if [ -f "${i}" ]; then
			einfo "Building format ${i}"
			TEXMFHOME="${S}/texmf:${S}/texmf-dist"\
				fmtutil --cnffile "${i}" --fmtdir "${S}/texmf-var/web2c" --all\
				|| die "failed to build format ${i}"
		fi
	done

	# Generate config files
	for i in "${S}"/texmf/lists/*;
	do
		grep '^!' "${i}" | tr ' ' '=' |sort|uniq >> "${T}/jobs"
	done

	for j in $(<"${T}/jobs");
	do
		command=$(echo ${j} | sed 's/.\(.*\)=.*/\1/')
		parameter=$(echo ${j} | sed 's/.*=\(.*\)/\1/')
		case "${command}" in
			addMap)
				echo "Map ${parameter}" >> "${S}/${PN}.cfg";;
			addMixedMap)
				echo "MixedMap ${parameter}" >> "${S}/${PN}.cfg";;
			addDvipsMap)
				echo "p	+${parameter}" >> "${S}/${PN}-config.ps";;
			addDvipdfmMap)
				echo "f	${parameter}" >> "${S}/${PN}-config";;
		esac
	done
}

# @FUNCTION: texlive-module_src_install
# @DESCRIPTION:
# exported function:
# Install texmf and config files to the system

texlive-module_src_install() {
	for i in texmf/fmtutil/format*.cnf; do
		[ -f "${i}" ] && etexlinks "${i}"
	done

	insinto /usr/share
	if use doc; then
		[ -d texmf-doc ] && doins -r texmf-doc
	else
		[ -d texmf/doc ] && rm -rf texmf/doc
		[ -d texmf-dist/doc ] && rm -rf texmf-dist/doc
	fi

	[ -d texmf ] && doins -r texmf
	[ -d texmf-dist ] && doins -r texmf-dist

	insinto /var/lib/texmf
	[ -d texmf-var ] && doins -r texmf-var/*

	insinto /etc/texmf/updmap.d
	[ -f "${S}/${PN}.cfg" ] && doins "${S}/${PN}.cfg"
	insinto /etc/texmf/dvips.d
	[ -f "${S}/${PN}-config.ps" ] && doins "${S}/${PN}-config.ps"
	insinto /etc/texmf/dvipdfm/config
	[ -f "${S}/${PN}-config" ] && doins "${S}/${PN}-config"

	texlive-common_handle_config_files
}

# @FUNCTION: texlive-module_pkg_postinst
# @DESCRIPTION:
# exported function:
# run texmf-update to ensure the tex installation is consistent with the
# installed texmf trees.

texlive-module_pkg_postinst() {
	if [ "$ROOT" = "/" ] && [ -x "${EPREFIX}"/usr/sbin/texmf-update ] ; then
		"${EPREFIX}"/usr/sbin/texmf-update
	else
		ewarn "Cannot run texmf-update for some reason."
		ewarn "Your texmf tree might be inconsistent with your configuration"
		ewarn "Please try to figure what has happened"
	fi
}

# @FUNCTION: texlive-module_pkg_postrm
# @DESCRIPTION:
# exported function:
# run texmf-update to ensure the tex installation is consistent with the
# installed texmf trees.

texlive-module_pkg_postrm() {
	if [ "$ROOT" = "/" ] && [ -x "${EPREFIX}"/usr/sbin/texmf-update ] ; then
		"${EPREFIX}"/usr/sbin/texmf-update
	else
		ewarn "Cannot run texmf-update for some reason."
		ewarn "Your texmf tree might be inconsistent with your configuration"
		ewarn "Please try to figure what has happened"
	fi
}

EXPORT_FUNCTIONS src_compile src_install pkg_postinst pkg_postrm
