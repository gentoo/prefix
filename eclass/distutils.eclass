# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/distutils.eclass,v 1.72 2010/02/08 09:35:38 pva Exp $

# @ECLASS: distutils.eclass
# @MAINTAINER:
# Gentoo Python Project <python@gentoo.org>
#
# Original author: Jon Nelson <jnelson@gentoo.org>
# @BLURB: Eclass for packages with build systems using Distutils
# @DESCRIPTION:
# The distutils eclass defines phase functions for packages with build systems using Distutils

inherit multilib python

case "${EAPI:-0}" in
	0|1)
		EXPORT_FUNCTIONS src_unpack src_compile src_install pkg_postinst pkg_postrm
		;;
	*)
		EXPORT_FUNCTIONS src_unpack src_prepare src_compile src_install pkg_postinst pkg_postrm
		;;
esac

if [[ -z "${PYTHON_DEPEND}" ]]; then
	DEPEND="virtual/python"
	RDEPEND="${DEPEND}"
fi

if has "${EAPI:-0}" 0 1 2; then
	python="python"
else
	# Use "$(PYTHON)" or "$(PYTHON -A)" instead of "${python}".
	python="die"
fi

# @ECLASS-VARIABLE: DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES
# @DESCRIPTION:
# Set this to use separate source directories for each enabled version of Python.

# @ECLASS-VARIABLE: DISTUTILS_GLOBAL_OPTIONS
# @DESCRIPTION:
# Global options passed to setup.py.

# @ECLASS-VARIABLE: DISTUTILS_SRC_TEST
# @DESCRIPTION:
# Type of test command used by distutils_src_test().
# IUSE and DEPEND are automatically adjusted, unless DISTUTILS_DISABLE_TEST_DEPENDENCY is set.
# Valid values:
#   setup.py
#   nosetests
#   py.test
#   trial [arguments]

# @ECLASS-VARIABLE: DISTUTILS_DISABLE_TEST_DEPENDENCY
# @DESCRIPTION:
# Disable modification of IUSE and DEPEND caused by setting of DISTUTILS_SRC_TEST.

if [[ -n "${DISTUTILS_SRC_TEST}" && ! "${DISTUTILS_SRC_TEST}" =~ ^(setup\.py|nosetests|py\.test|trial(\ .*)?)$ ]]; then
	die "'DISTUTILS_SRC_TEST' variable has unsupported value '${DISTUTILS_SRC_TEST}'"
fi

if [[ -z "${DISTUTILS_DISABLE_TEST_DEPENDENCY}" ]]; then
	if [[ "${DISTUTILS_SRC_TEST}" == "nosetests" ]]; then
		IUSE="test"
		DEPEND+="${DEPEND:+ }test? ( dev-python/nose )"
	elif [[ "${DISTUTILS_SRC_TEST}" == "py.test" ]]; then
		IUSE="test"
		DEPEND+="${DEPEND:+ }test? ( dev-python/py )"
	# trial requires an argument, which is usually equal to "${PN}".
	elif [[ "${DISTUTILS_SRC_TEST}" =~ ^trial(\ .*)?$ ]]; then
		IUSE="test"
		DEPEND+="${DEPEND:+ }test? ( dev-python/twisted )"
	fi
fi

if [[ -n "${DISTUTILS_SRC_TEST}" ]]; then
	EXPORT_FUNCTIONS src_test
fi

# @ECLASS-VARIABLE: DISTUTILS_DISABLE_VERSIONING_OF_PYTHON_SCRIPTS
# @DESCRIPTION:
# Set this to disable renaming of Python scripts containing versioned shebangs
# and generation of wrapper scripts.

# @ECLASS-VARIABLE: DOCS
# @DESCRIPTION:
# Additional documentation files installed by distutils_src_install().

_distutils_get_build_dir() {
	if [[ -n "${SUPPORT_PYTHON_ABIS}" && -z "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]]; then
		echo "build-${PYTHON_ABI}"
	else
		echo "build"
	fi
}

_distutils_get_PYTHONPATH() {
	if [[ -n "${SUPPORT_PYTHON_ABIS}" && -z "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]]; then
		ls -d build-${PYTHON_ABI}/lib* 2> /dev/null
	else
		ls -d build/lib* 2> /dev/null
	fi
}

_distutils_hook() {
	if [[ "$#" -ne 1 ]]; then
		die "${FUNCNAME}() requires 1 argument"
	fi
	if [[ "$(type -t "distutils_src_${EBUILD_PHASE}_$1_hook")" == "function" ]]; then
		"distutils_src_${EBUILD_PHASE}_$1_hook"
	fi
}

# @FUNCTION: distutils_src_unpack
# @DESCRIPTION:
# The distutils src_unpack function. This function is exported.
distutils_src_unpack() {
	if [[ "${EBUILD_PHASE}" != "unpack" ]]; then
		die "${FUNCNAME}() can be used only in src_unpack() phase"
	fi

	unpack ${A}
	cd "${S}"

	has "${EAPI:-0}" 0 1 && distutils_src_prepare
}

# @FUNCTION: distutils_src_prepare
# @DESCRIPTION:
# The distutils src_prepare function. This function is exported.
distutils_src_prepare() {
	if ! has "${EAPI:-0}" 0 1 && [[ "${EBUILD_PHASE}" != "prepare" ]]; then
		die "${FUNCNAME}() can be used only in src_prepare() phase"
	fi

	# Delete ez_setup files to prevent packages from installing Setuptools on their own.
	local ez_setup_existence="0"
	[[ -d ez_setup || -f ez_setup.py ]] && ez_setup_existence="1"
	rm -fr ez_setup*
	if [[ "${ez_setup_existence}" == "1" ]]; then
		echo "def use_setuptools(*args, **kwargs): pass" > ez_setup.py
	fi

	# Delete distribute_setup files to prevent packages from installing Distribute on their own.
	local distribute_setup_existence="0"
	[[ -d distribute_setup || -f distribute_setup.py ]] && distribute_setup_existence="1"
	rm -fr distribute_setup*
	if [[ "${distribute_setup_existence}" == "1" ]]; then
		echo "def use_setuptools(*args, **kwargs): pass" > distribute_setup.py
	fi

	if [[ -n "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]]; then
		python_copy_sources
	fi
}

# @FUNCTION: distutils_src_compile
# @DESCRIPTION:
# The distutils src_compile function. This function is exported.
# In ebuilds of packages supporting installation for multiple versions of Python, this function
# calls distutils_src_compile_pre_hook() and distutils_src_compile_post_hook(), if they are defined.
distutils_src_compile() {
	if [[ "${EBUILD_PHASE}" != "compile" ]]; then
		die "${FUNCNAME}() can be used only in src_compile() phase"
	fi

	if [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
		distutils_building() {
			_distutils_hook pre

			echo "$(PYTHON)" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" build -b "$(_distutils_get_build_dir)" "$@"
			"$(PYTHON)" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" build -b "$(_distutils_get_build_dir)" "$@" || return "$?"

			_distutils_hook post
		}
		python_execute_function ${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES:+-s} distutils_building "$@"
	else
		echo "$(PYTHON -A)" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" build "$@"
		"$(PYTHON -A)" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" build "$@" || die "Building failed"
	fi
}

# @FUNCTION: distutils_src_test
# @DESCRIPTION:
# The distutils src_test function. This function is exported, when DISTUTILS_SRC_TEST variable is set.
distutils_src_test() {
	if [[ "${DISTUTILS_SRC_TEST}" == "setup.py" ]]; then
		if [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
			distutils_testing() {
				echo PYTHONPATH="$(_distutils_get_PYTHONPATH)" "$(PYTHON)" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" $([[ -z "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]] && echo build -b "$(_distutils_get_build_dir)") test "$@"
				PYTHONPATH="$(_distutils_get_PYTHONPATH)" "$(PYTHON)" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" $([[ -z "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]] && echo build -b "$(_distutils_get_build_dir)") test "$@"
			}
			python_execute_function ${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES:+-s} distutils_testing "$@"
		else
			echo PYTHONPATH="$(_distutils_get_PYTHONPATH)" "$(PYTHON -A)" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" test "$@" || die "Testing failed"
			PYTHONPATH="$(_distutils_get_PYTHONPATH)" "$(PYTHON -A)" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" test "$@" || die "Testing failed"
		fi
	elif [[ "${DISTUTILS_SRC_TEST}" == "nosetests" ]]; then
		python_execute_nosetests -P '$(_distutils_get_PYTHONPATH)' ${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES:+-s} -- "$@"
	elif [[ "${DISTUTILS_SRC_TEST}" == "py.test" ]]; then
		python_execute_py.test -P '$(_distutils_get_PYTHONPATH)' ${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES:+-s} -- "$@"
	# trial requires an argument, which is usually equal to "${PN}".
	elif [[ "${DISTUTILS_SRC_TEST}" =~ ^trial(\ .*)?$ ]]; then
		local trial_arguments
		if [[ "${DISTUTILS_SRC_TEST}" == "trial "* ]]; then
			trial_arguments="${DISTUTILS_SRC_TEST#trial }"
		else
			trial_arguments="${PN}"
		fi

		python_execute_trial -P '$(_distutils_get_PYTHONPATH)' ${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES:+-s} -- ${trial_arguments} "$@"
	else
		die "'DISTUTILS_SRC_TEST' variable has unsupported value '${DISTUTILS_SRC_TEST}'"
	fi
}

# @FUNCTION: distutils_src_install
# @DESCRIPTION:
# The distutils src_install function. This function is exported.
# In ebuilds of packages supporting installation for multiple versions of Python, this function
# calls distutils_src_install_pre_hook() and distutils_src_install_post_hook(), if they are defined.
# It also installs some standard documentation files (AUTHORS, Change*, CHANGELOG, CONTRIBUTORS,
# KNOWN_BUGS, MAINTAINERS, MANIFEST*, NEWS, PKG-INFO, README*, TODO).
distutils_src_install() {
	if [[ "${EBUILD_PHASE}" != "install" ]]; then
		die "${FUNCNAME}() can be used only in src_install() phase"
	fi

	if [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
		if [[ -z "${DISTUTILS_DISABLE_VERSIONING_OF_PYTHON_SCRIPTS}" && "${BASH_VERSINFO[0]}" -ge 4 ]]; then
			declare -A wrapper_scripts=()

			rename_scripts_with_versioned_shebangs() {
				if [[ -d "${ED}usr/bin" ]]; then
					cd "${ED}usr/bin"

					local file
					for file in *; do
						if [[ -f "${file}" && ! "${file}" =~ [[:digit:]]+\.[[:digit:]]+$ && "$(head -n1 "${file}")" =~ ^'#!'.*python[[:digit:]]+\.[[:digit:]]+ ]]; then
							mv "${file}" "${file}-${PYTHON_ABI}" || die "Renaming of '${file}' failed"
							wrapper_scripts+=(["${ED}usr/bin/${file}"]=)
						fi
					done
				fi
			}
		fi

		if [[ -n "${DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES}" ]]; then
			installation() {
				_distutils_hook pre

				# need this for python-2.5 + setuptools in cases where
				# a package uses distutils but does not install anything
				# in site-packages. (eg. dev-java/java-config-2.x)
				# - liquidx (14/08/2006)
				pylibdir="$("$(PYTHON)" -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())')"
				# what comes out of python, includes our prefix, and the code
				# below doesn't keep that in mind -- grobian
				pylibdir=${pylibdir#${EPREFIX}}
				[[ -n "${pylibdir}" ]] && dodir "${pylibdir}"

				echo "$(PYTHON)" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" install --root="${D}" --no-compile "$@"
				"$(PYTHON)" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" install --root="${D}" --no-compile "$@" || return "$?"

				if [[ -z "${DISTUTILS_DISABLE_VERSIONING_OF_PYTHON_SCRIPTS}" && "${BASH_VERSINFO[0]}" -ge "4" ]]; then
					rename_scripts_with_versioned_shebangs
				fi

				_distutils_hook post
			}
			python_execute_function -s installation "$@"
		else
			installation() {
				_distutils_hook pre

				# need this for python-2.5 + setuptools in cases where
				# a package uses distutils but does not install anything
				# in site-packages. (eg. dev-java/java-config-2.x)
				# - liquidx (14/08/2006)
				pylibdir="$("$(PYTHON)" -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())')"
				# what comes out of python, includes our prefix, and the code
				# below doesn't keep that in mind -- grobian
				pylibdir=${pylibdir#${EPREFIX}}
				[[ -n "${pylibdir}" ]] && dodir "${pylibdir}"

				echo "$(PYTHON)" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" build -b "build-${PYTHON_ABI}" install --root="${D}" --no-compile "$@"
				"$(PYTHON)" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" build -b "build-${PYTHON_ABI}" install --root="${D}" --no-compile "$@" || return "$?"

				if [[ -z "${DISTUTILS_DISABLE_VERSIONING_OF_PYTHON_SCRIPTS}" && "${BASH_VERSINFO[0]}" -ge "4" ]]; then
					rename_scripts_with_versioned_shebangs
				fi

				_distutils_hook post
			}
			python_execute_function installation "$@"
		fi

		if [[ -z "${DISTUTILS_DISABLE_VERSIONING_OF_PYTHON_SCRIPTS}" && "${#wrapper_scripts[@]}" -ne "0" && "${BASH_VERSINFO[0]}" -ge "4" ]]; then
			python_generate_wrapper_scripts "${!wrapper_scripts[@]}"
		fi
		unset wrapper_scripts
	else
		# Mark the package to be rebuilt after a Python upgrade.
		python_need_rebuild

		# need this for python-2.5 + setuptools in cases where
		# a package uses distutils but does not install anything
		# in site-packages. (eg. dev-java/java-config-2.x)
		# - liquidx (14/08/2006)
		pylibdir="$("$(PYTHON -A)" -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())')"
		# what comes out of python, includes our prefix, and the code below doesn't
		# keep that in mind -- grobian
		pylibdir=${pylibdir#${EPREFIX}}
		[[ -n "${pylibdir}" ]] && dodir "${pylibdir}"

		echo "$(PYTHON -A)" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" install --root="${D}" --no-compile "$@"
		"$(PYTHON -A)" setup.py "${DISTUTILS_GLOBAL_OPTIONS[@]}" install --root="${D}" --no-compile "$@" || die "Installation failed"
	fi

	if [[ -e "${ED}usr/local" ]]; then
		die "Illegal installation into /usr/local"
	fi

	local default_docs
	default_docs="AUTHORS Change* CHANGELOG CONTRIBUTORS KNOWN_BUGS MAINTAINERS MANIFEST* NEWS PKG-INFO README* TODO"

	local doc
	for doc in ${default_docs}; do
		[[ -s "${doc}" ]] && dodoc "${doc}"
	done

	if [[ -n "${DOCS}" ]]; then
		dodoc ${DOCS} || die "dodoc failed"
	fi
}

# @FUNCTION: distutils_pkg_postinst
# @DESCRIPTION:
# The distutils pkg_postinst function. This function is exported.
# When PYTHON_MODNAME variable is set, then this function calls python_mod_optimize() with modules
# specified in PYTHON_MODNAME variable. Otherwise it calls python_mod_optimize() with module, whose
# name is equal to name of current package, if this module exists.
distutils_pkg_postinst() {
	if [[ "${EBUILD_PHASE}" != "postinst" ]]; then
		die "${FUNCNAME}() can be used only in pkg_postinst() phase"
	fi

	local pylibdir pymod
	if [[ -z "${PYTHON_MODNAME}" ]]; then
		for pylibdir in "${EROOT}"/usr/$(get_libdir)/python*; do
			if [[ -d "${pylibdir}/site-packages/${PN}" ]]; then
				PYTHON_MODNAME="${PN}"
			fi
		done
	fi

	if ! has "${EAPI:-0}" 0 1 2 || [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
		python_mod_optimize ${PYTHON_MODNAME}
	else
		for pymod in ${PYTHON_MODNAME}; do
			python_mod_optimize "$(python_get_sitedir)/${pymod}"
		done
	fi
}

# @FUNCTION: distutils_pkg_postrm
# @DESCRIPTION:
# The distutils pkg_postrm function. This function is exported.
# When PYTHON_MODNAME variable is set, then this function calls python_mod_cleanup() with modules
# specified in PYTHON_MODNAME variable. Otherwise it calls python_mod_cleanup() with module, whose
# name is equal to name of current package, if this module exists.
distutils_pkg_postrm() {
	if [[ "${EBUILD_PHASE}" != "postrm" ]]; then
		die "${FUNCNAME}() can be used only in pkg_postrm() phase"
	fi

	local pylibdir pymod
	if [[ -z "${PYTHON_MODNAME}" ]]; then
		for pylibdir in "${EROOT}"/usr/$(get_libdir)/python*; do
			if [[ -d "${pylibdir}/site-packages/${PN}" ]]; then
				PYTHON_MODNAME="${PN}"
			fi
		done
	fi

	if [[ -n "${PYTHON_MODNAME}" ]]; then
		if ! has "${EAPI:-0}" 0 1 2 || [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
			python_mod_cleanup ${PYTHON_MODNAME}
		else
			for pymod in ${PYTHON_MODNAME}; do
				for pylibdir in "${EROOT}"/usr/$(get_libdir)/python*; do
					if [[ -d "${pylibdir}/site-packages/${pymod}" ]]; then
						python_mod_cleanup "${pylibdir#${EROOT}}/site-packages/${pymod}"
					fi
				done
			done
		fi
	else
		python_mod_cleanup
	fi
}

# @FUNCTION: distutils_python_version
# @DESCRIPTION:
# Deprecated wrapper function for deprecated python_version().
distutils_python_version() {
	if ! has "${EAPI:-0}" 0 1 2; then
		eerror "Use PYTHON() and/or python_get_*() instead of ${FUNCNAME}()."
		die "${FUNCNAME}() cannot be used in this EAPI"
	fi

	python_version
}

# @FUNCTION: distutils_python_tkinter
# @DESCRIPTION:
# Deprecated wrapper function for python_tkinter_exists().
distutils_python_tkinter() {
	if ! has "${EAPI:-0}" 0 1 2; then
		eerror "Use python_tkinter_exists() instead of ${FUNCNAME}()."
		die "${FUNCNAME}() cannot be used in this EAPI"
	fi

	python_tkinter_exists
}
