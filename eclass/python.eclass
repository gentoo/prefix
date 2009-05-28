# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/python.eclass,v 1.55 2009/05/27 22:49:32 betelgeuse Exp $

# @ECLASS: python.eclass
# @MAINTAINER:
# python@gentoo.org
#
# original author: Alastair Tse <liquidx@gentoo.org>
# @BLURB: A Utility Eclass that should be inherited by anything that deals with Python or Python modules.
# @DESCRIPTION:
# Some useful functions for dealing with python.
inherit alternatives multilib


if [[ -n "${NEED_PYTHON}" ]] ; then
	PYTHON_ATOM=">=dev-lang/python-${NEED_PYTHON}"
	DEPEND="${PYTHON_ATOM}"
	RDEPEND="${DEPEND}"
else
	PYTHON_ATOM="dev-lang/python"
fi

__python_eclass_test() {
	__python_version_extract 2.3
	echo -n "2.3 -> PYVER: $PYVER PYVER_MAJOR: $PYVER_MAJOR"
	echo " PYVER_MINOR: $PYVER_MINOR PYVER_MICRO: $PYVER_MICRO"
	__python_version_extract 2.3.4
	echo -n "2.3.4 -> PYVER: $PYVER PYVER_MAJOR: $PYVER_MAJOR"
	echo " PYVER_MINOR: $PYVER_MINOR PYVER_MICRO: $PYVER_MICRO"
	__python_version_extract 2.3.5
	echo -n "2.3.5 -> PYVER: $PYVER PYVER_MAJOR: $PYVER_MAJOR"
	echo " PYVER_MINOR: $PYVER_MINOR PYVER_MICRO: $PYVER_MICRO"
	__python_version_extract 2.4
	echo -n "2.4 -> PYVER: $PYVER PYVER_MAJOR: $PYVER_MAJOR"
	echo " PYVER_MINOR: $PYVER_MINOR PYVER_MICRO: $PYVER_MICRO"
	__python_version_extract 2.5b3
	echo -n "2.5b3 -> PYVER: $PYVER PYVER_MAJOR: $PYVER_MAJOR"
	echo " PYVER_MINOR: $PYVER_MINOR PYVER_MICRO: $PYVER_MICRO"
}

# @FUNCTION: python_version
# @DESCRIPTION:
# Run without arguments and it will export the version of python
# currently in use as $PYVER; sets PYVER/PYVER_MAJOR/PYVER_MINOR
__python_version_extract() {
	local verstr=$1
	export PYVER_MAJOR=${verstr:0:1}
	export PYVER_MINOR=${verstr:2:1}
	if [[ ${verstr:3:1} == . ]]; then
		export PYVER_MICRO=${verstr:4}
	fi
	export PYVER="${PYVER_MAJOR}.${PYVER_MINOR}"
}

python_version() {
	[[ -n "${PYVER}" ]] && return 0
	local tmpstr
	python=${python:-"$(type -P python)"}
	tmpstr="$(${python} -V 2>&1 )"
	export PYVER_ALL="${tmpstr#Python }"
	__python_version_extract $PYVER_ALL
}

# @ECLASS-VARIABLE: PYTHON_USE_WITH
# @DESCRIPTION:
# Set this to a space separated list of use flags
# the python slot in use must be built with.

# @ECLASS-VARIABLE: PYTHON_USE_WITH_OR
# @DESCRIPTION:
# Set this to a space separated list of use flags
# of which one must be turned on for the slot of
# in use.

# @ECLASS-VARIABLE: PYTHON_USE_WITH_OPT
# @DESCRIPTION:
# Set this if you need to make either PYTHON_USE_WITH or
# PYTHON_USE_WITH_OR atoms conditional under a use flag.

# @FUNCTION: python_pkg_setup
# @DESCRIPTION:
# Makes sure PYTHON_USE_WITH or PYTHON_USE_WITH_OR listed use flags
# are respected. Only exported if one of those variables is set.
if ! has ${EAPI} 0 1 && [[ -n ${PYTHON_USE_WITH} || -n ${PYTHON_USE_WITH_OR} ]]; then
	python_pkg_setup_fail() {
		eerror "${1}"
		die "${1}"
	}

	python_pkg_setup() {
		[[ ${PYTHON_USE_WITH_OPT} ]] && use !${PYTHON_USE_WITH_OPT} && return

		python_version
		local failed
		local pyatom="dev-lang/python:${PYVER}"

		for use in ${PYTHON_USE_WITH}; do
			if ! has_version "${pyatom}[${use}]"; then
				python_pkg_setup_fail \
					"Please rebuild ${pyatom} with use flags: ${PYTHON_USE_WITH}"
			fi
		done

		for use in ${PYTHON_USE_WITH_OR}; do
			if has_version "${pyatom}[${use}]"; then
				return
			fi
		done

		if [[ ${PYTHON_USE_WITH_OR} ]]; then
			python_pkg_setup_fail \
				"Please rebuild ${pyatom} with one of: ${PYTHON_USE_WITH_OR}"
		fi
	}

	EXPORT_FUNCTIONS pkg_setup

	if [[ ${PYTHON_USE_WITH} ]]; then
		PYTHON_USE_WITH_ATOM="${PYTHON_ATOM}[${PYTHON_USE_WITH/ /,}]"
	elif [[ ${PYTHON_USE_WITH_OR} ]]; then
		PYTHON_USE_WITH_ATOM="|| ( "
		for use in ${PYTHON_USE_WITH_OR}; do
			PYTHON_USE_WITH_ATOM="
				${PYTHON_USE_WITH_ATOM}
				${PYTHON_ATOM}[${use}]"
		done
		PYTHON_USE_WITH_ATOM="${PYTHON_USE_WITH_ATOM} )"
	fi
	if [[ ${PYTHON_USE_WITH_OPT} ]]; then
		PYTHON_USE_WITH_ATOM="${PYTHON_USE_WITH_OPT}? ( ${PYTHON_USE_WITH_ATOM} )"
	fi
	DEPEND="${PYTHON_USE_WITH_ATOM}"
	RDEPEND="${PYTHON_USE_WITH_ATOM}"
fi

# @FUNCTION: python_disable_pyc
# @DESCRIPTION:
# Tells python not to automatically recompile modules to .pyc/.pyo
# even if the timestamps/version stamps don't match. This is done
# to protect sandbox.
#
# note:   supported by >=dev-lang/python-2.2.3-r3 only.
#
python_disable_pyc() {
	export PYTHONDONTWRITEBYTECODE=1 # For 2.6 and above
	export PYTHON_DONTCOMPILE=1 # For 2.5 and below
}

# @FUNCTION: python_enable_pyc
# @DESCRIPTION:
# Tells python to automatically recompile modules to .pyc/.pyo if the
# timestamps/version stamps change
python_enable_pyc() {
	unset PYTHONDONTWRITEBYTECODE
	unset PYTHON_DONTCOMPILE
}

python_disable_pyc

# @FUNCTION: python_need_rebuild
# @DESCRIPTION: Run without arguments, specifies that the package should be
# rebuilt after a python upgrade.
python_need_rebuild() {
	python_version
	export PYTHON_NEED_REBUILD=${PYVER}
}

# @FUNCTION: python_get_libdir
# @DESCRIPTION:
# Run without arguments, returns the python library dir
python_get_libdir() {
	python_version
	echo "/usr/$(get_libdir)/python${PYVER}"
}

# @FUNCTION: python_get_sitedir
# @DESCRIPTION:
# Run without arguments, returns the python site-packages dir
python_get_sitedir() {
	echo "$(python_get_libdir)/site-packages"
}

# @FUNCTION: python_makesym
# @DESCRIPTION:
# Run without arguments, it will create the /usr/bin/python symlinks
# to the latest installed version
python_makesym() {
	alternatives_auto_makesym "/usr/bin/python" "python[0-9].[0-9]"
	alternatives_auto_makesym "/usr/bin/python2" "python2.[0-9]"
}

# @FUNCTION: python_tkinter_exists
# @DESCRIPTION:
# Run without arguments, checks if python was compiled with Tkinter
# support.  If not, prints an error message and dies.
python_tkinter_exists() {
	if ! python -c "import Tkinter" >/dev/null 2>&1; then
		eerror "You need to recompile python with Tkinter support."
		eerror "Try adding: 'dev-lang/python tk'"
		eerror "in to ${EPREFIX}/etc/portage/package.use"
		echo
		die "missing tkinter support with installed python"
	fi
}

# @FUNCTION: python_mod_exists
# @USAGE: < module >
# @DESCRIPTION:
# Run with the module name as an argument. it will check if a
# python module is installed and loadable. it will return
# TRUE(0) if the module exists, and FALSE(1) if the module does
# not exist.
#
# Example:
#         if python_mod_exists gtk; then
#             echo "gtk support enabled"
#         fi
python_mod_exists() {
	[[ "$1" ]] || die "${FUNCNAME} requires an argument!"
	python -c "import $1" >/dev/null 2>&1
}

# @FUNCTION: python_mod_compile
# @USAGE: < file > [more files ...]
# @DESCRIPTION:
# Given filenames, it will pre-compile the module's .pyc and .pyo.
# This function should only be run in pkg_postinst()
#
# Example:
#         python_mod_compile /usr/lib/python2.3/site-packages/pygoogle.py
#
python_mod_compile() {
	local f myroot myfiles=()

	# Check if phase is pkg_postinst()
	[[ ${EBUILD_PHASE} != postinst ]] &&\
		die "${FUNCNAME} should only be run in pkg_postinst()"

	# allow compiling for older python versions
	if [[ "${PYTHON_OVERRIDE_PYVER}" ]]; then
		PYVER=${PYTHON_OVERRIDE_PYVER}
	else
		python_version
	fi

	# strip trailing slash
	myroot="${ROOT%/}"

	# respect ROOT
	for f in "$@"; do
		[[ -f "${myroot}/${f}" ]] && myfiles+=("${myroot}/${f}")
	done

	if ((${#myfiles[@]})); then
		python${PYVER} ${myroot}/usr/$(get_libdir)/python${PYVER}/py_compile.py "${myfiles[@]}"
		python${PYVER} -O ${myroot}/usr/$(get_libdir)/python${PYVER}/py_compile.py "${myfiles[@]}"
	else
		ewarn "No files to compile!"
	fi
}

# @FUNCTION: python_mod_optimize
# @USAGE: [ path ]
# @DESCRIPTION:
# If no arguments supplied, it will recompile all modules under
# sys.path (eg. /usr/lib/python2.3, /usr/lib/python2.3/site-packages/ ..)
# no recursively
#
# If supplied with arguments, it will recompile all modules recursively
# in the supplied directory
# This function should only be run in pkg_postinst()
#
# Options passed to this function are passed to compileall.py
#
# Example:
#         python_mod_optimize /usr/share/codegen
python_mod_optimize() {
	local myroot mydirs=() myfiles=() myopts=()

	# Check if phase is pkg_postinst()
	[[ ${EBUILD_PHASE} != postinst ]] &&\
		die "${FUNCNAME} should only be run in pkg_postinst()"

	# strip trailing slash
	myroot="${EROOT%/}"

	# respect ROOT and options passed to compileall.py
	while (($#)); do
		case $1 in
			-l|-f|-q)
				myopts+=("$1")
				;;
			-d|-x)
				myopts+=("$1" "$2")
				shift
				;;
			-*)
				ewarn "${FUNCNAME}: Ignoring compile option $1"
				;;
			*)
				if [[ -d "${myroot}"/$1 ]]; then
					mydirs+=("${myroot}/$1")
				elif [[ -f "${myroot}"/$1 ]]; then
					# Files are passed to python_mod_compile which is ROOT-aware
					myfiles+=("$1")
				elif [[ -e "${myroot}/$1" ]]; then
					ewarn "${myroot}/$1 is not a file or directory!"
				else
					ewarn "${myroot}/$1 doesn't exist!"
				fi
				;;
		esac
		shift
	done

	# allow compiling for older python versions
	if [ -n "${PYTHON_OVERRIDE_PYVER}" ]; then
		PYVER=${PYTHON_OVERRIDE_PYVER}
	else
		python_version
	fi

	# set additional opts
	myopts+=(-q)

	ebegin "Byte compiling python modules for python-${PYVER} .."
	if ((${#mydirs[@]})); then
		python${PYVER} \
			"${myroot}"/usr/$(get_libdir)/python${PYVER}/compileall.py \
			"${myopts[@]}" "${mydirs[@]}"
		python${PYVER} -O \
			"${myroot}"/usr/$(get_libdir)/python${PYVER}/compileall.py \
			"${myopts[@]}" "${mydirs[@]}"
	fi

	if ((${#myfiles[@]})); then
		python_mod_compile "${myfiles[@]}"
	fi

	eend $?
}

# @FUNCTION: python_mod_cleanup
# @USAGE: [ dir ]
# @DESCRIPTION:
# Run with optional arguments, where arguments are directories of
# python modules. if none given, it will look in /usr/lib/python[0-9].[0-9]
#
# It will recursively scan all compiled python modules in the directories
# and determine if they are orphaned (eg. their corresponding .py is missing.)
# if they are, then it will remove their corresponding .pyc and .pyo
#
# This function should only be run in pkg_postrm()
python_mod_cleanup() {
	local SEARCH_PATH=() myroot src_py

	# Check if phase is pkg_postrm()
	[[ ${EBUILD_PHASE} != postrm ]] &&\
		die "${FUNCNAME} should only be run in pkg_postrm()"

	# strip trailing slash
	myroot="${ROOT%/}"

	if (($#)); then
		SEARCH_PATH=("${@#${EPREFIX}/}")
		SEARCH_PATH=("${SEARCH_PATH[@]/#/$myroot${EPREFIX}/}")
	else
		SEARCH_PATH=("${myroot}${EPREFIX}"/usr/lib*/python*/site-packages)
	fi

	for path in "${SEARCH_PATH[@]}"; do
		einfo "Cleaning orphaned Python bytecode from ${path} .."
		find "${path}" -name '*.py[co]' -print0 | while read -rd ''; do
			src_py="${REPLY%[co]}"
			[[ -f "${src_py}" ]] && continue
			einfo "Purging ${src_py}[co]"
			rm -f "${src_py}"[co]
		done

		# attempt to remove directories that maybe empty
		find "${path}" -type d | sort -r | while read -r dir; do
			rmdir "${dir}" 2>/dev/null
		done
	done
}
