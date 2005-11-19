# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/distutils.eclass,v 1.28 2005/07/11 15:08:06 swegener Exp $
#
# Author: Jon Nelson <jnelson@gentoo.org>
# Current Maintainer: Alastair Tse <liquidx@gentoo.org>
#
# The distutils eclass is designed to allow easier installation of
# distutils-based python modules and their incorporation into
# the Gentoo Linux system.
#
# - Features:
# distutils_src_compile()    - does python setup.py build
# distutils_src_install()    - does python setup.py install and install docs
# distutils_python_version() - sets PYVER/PYVER_MAJOR/PYVER_MINOR
# distutils_python_tkinter() - checks for tkinter support in python
#
# - Variables:
# PYTHON_SLOT_VERSION     - for Zope support
# DOCS                    - additional DOCS

inherit python eutils

# This helps make it possible to add extensions to python slots.
# Normally only a -py21- ebuild would set PYTHON_SLOT_VERSION.
if [ "${PYTHON_SLOT_VERSION}" = 2.1 ] ; then
	DEPEND="=dev-lang/python-2.1*"
	python="python2.1"
else
	DEPEND="virtual/python"
	python="python"
fi

distutils_src_compile() {
	${python} setup.py build "$@" || die "compilation failed"
}

distutils_src_install() {
	if has_version ">=dev-lang/python-2.3"; then
		${python} setup.py install --root=${DEST} --no-compile "$@" || die
	else
		${python} setup.py install --root=${DEST} "$@" || die
	fi

	DDOCS="CHANGELOG COPYRIGHT KNOWN_BUGS MAINTAINERS PKG-INFO"
	DDOCS="${DDOCS} CONTRIBUTORS LICENSE COPYING*"
	DDOCS="${DDOCS} Change* MANIFEST* README*"

	for doc in ${DDOCS}; do
		[ -s "$doc" ] && dodoc $doc
	done

	[ -n "${DOCS}" ] && dodoc ${DOCS}

	# deprecated! please use DOCS instead.
	[ -n "${mydoc}" ] && dodoc ${mydoc}
}

# generic pyc/pyo cleanup script.

distutils_pkg_postrm() {
	PYTHON_MODNAME=${PYTHON_MODNAME:-${PN}}

	if has_version ">=dev-lang/python-2.3"; then
		ebegin "Performing Python Module Cleanup .."
		if [ -n "${PYTHON_MODNAME}" ]; then
			for pymod in ${PYTHON_MODNAME}; do
				for moddir in "`ls -d --color=none -1 ${ROOT}${PREFIX}usr/$(get_libdir)/python*/site-packages/${pymod} 2> /dev/null`"; do
					python_mod_cleanup ${moddir}
				done
			done
		else
			python_mod_cleanup
		fi
		eend 0
	fi
}

# this is a generic optimization, you should override it if your package
# installs things in another directory

distutils_pkg_postinst() {
	PYTHON_MODNAME=${PYTHON_MODNAME:-${PN}}

	if has_version ">=dev-lang/python-2.3"; then
		python_version
		for pymod in "${PYTHON_MODNAME}"; do
			if [ -d "${ROOT}usr/$(get_libdir)/python${PYVER}/site-packages/${pymod}" ]; then
				python_mod_optimize ${ROOT}usr/$(get_libdir)/python${PYVER}/site-packages/${pymod}
			fi
		done
	fi
}

# e.g. insinto ${ROOT}/usr/include/python${PYVER}

distutils_python_version() {
	local tmpstr="$(${python} -V 2>&1 )"
	export PYVER_ALL="${tmpstr#Python }"

	export PYVER_MAJOR=$(echo ${PYVER_ALL} | cut -d. -f1)
	export PYVER_MINOR=$(echo ${PYVER_ALL} | cut -d. -f2)
	export PYVER_MICRO=$(echo ${PYVER_ALL} | cut -d. -f3-)
	export PYVER="${PYVER_MAJOR}.${PYVER_MINOR}"
}

# checks for if tkinter support is compiled into python
distutils_python_tkinter() {
	if ! python -c "import Tkinter" >/dev/null 2>&1; then
		eerror "You need to recompile python with Tkinter support."
		eerror "That means: USE='tcltk' emerge python"
		echo
		die "missing tkinter support with installed python"
	fi
}

EXPORT_FUNCTIONS src_compile src_install pkg_postinst pkg_postrm
