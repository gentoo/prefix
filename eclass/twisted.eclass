# Copyright 2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License, v2 or later
# $Header: /var/cvsroot/gentoo-x86/eclass/twisted.eclass,v 1.6 2006/05/29 18:46:08 marienz Exp $
#
# Author: Marien Zwart <marienz@gentoo.org>
#
# eclass to aid installing and testing twisted packages.
#
# you should set MY_PACKAGE to something like 'Names' before inheriting.
# you may set MY_PV to the right version (defaults to PV).
#
# twisted_src_test relies on the package installing twisted.names to
# have a ${PN} of twisted-names.

inherit distutils versionator eutils

MY_PV=${MY_PV:-${PV}}
MY_VERSION=$(get_version_component_range 1-2 ${MY_PV})
MY_P=Twisted${MY_PACKAGE}-${MY_PV}

HOMEPAGE="http://www.twistedmatrix.com/"
SRC_URI="http://tmrc.mit.edu/mirror/twisted/${MY_PACKAGE}/${MY_VERSION}/${MY_P}.tar.bz2"

LICENSE="MIT"
SLOT="0"

IUSE=""

S="${WORKDIR}/${MY_P}"

twisted_src_test() {
	python_version
	# This is a hack to make tests work without installing to the live
	# filesystem. We copy the twisted site-packages to a temporary
	# dir, install there, and run from there.
	local spath="usr/$(get_libdir)/python${PYVER}/site-packages/"
	mkdir -p "${T}/${spath}"
	cp -R "${ROOT}${spath}/twisted" "${T}/${spath}" || die

	# We have to get rid of the existing version of this package
	# instead of just installing on top of it, since if the existing
	# package has tests in files the version we are installing does
	# not have we end up running fex twisted-names-0.3.0 tests when
	# downgrading to twisted-names-0.1.0-r1.
	rm -rf "${T}/${spath}/${PN/-//}"

	if has_version ">=dev-lang/python-2.3"; then
		"${python}" setup.py install --root="${T}" --no-compile --force \
			--install-lib="${spath}" || die
	else
		"${python}" setup.py install --root="${T}" --force \
			--install-lib="${spath}" || die
	fi
	cd "${T}/${spath}" || die
	local trialopts
	if ! has_version ">=dev-python/twisted-2.2"; then
		trialopts=-R
	fi
	PATH="${T}/usr/bin:${PATH}" PYTHONPATH="${T}/${spath}" \
		trial ${trialopts} ${PN/-/.} || die "trial failed"
	cd "${S}"
	rm -rf "${T}/${spath}"
}

twisted_src_install() {
	python_version
	# The explicit --install-lib here and in src_test is needed to
	# make everything (core and all subpackages) go into lib64 on
	# amd64. Without it pure python subpackages install into lib while
	# stuff with c extensions goes into lib64.
	distutils_src_install \
		--install-lib="usr/$(get_libdir)/python${PYVER}/site-packages/"

	if [[ -d doc/man ]]; then
		doman doc/man/*
	fi

	if [[ -d doc ]]; then
		insinto /usr/share/doc/${PF}
		doins -r $(find doc -mindepth 1 -maxdepth 1 -not -name man)
	fi
}

update_plugin_cache() {
	einfo "Updating twisted plugin cache..."
	python_version
	# we have to remove the cache or removed plugins won't be removed
	# from the cache (http://twistedmatrix.com/bugs/issue926)
	rm "${ROOT}usr/$(get_libdir)/python${PYVER}/site-packages/twisted/plugins/dropin.cache"
	# notice we have to use getPlugIns here for <=twisted-2.0.1 compatibility
	python -c "from twisted.plugin import IPlugin, getPlugIns;list(getPlugIns(IPlugin))"
}

twisted_pkg_postrm() {
	distutils_pkg_postrm
	update_plugin_cache
}

twisted_pkg_postinst() {
	distutils_pkg_postinst
	update_plugin_cache
}

EXPORT_FUNCTIONS src_test src_install pkg_postrm pkg_postinst
