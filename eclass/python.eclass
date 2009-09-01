# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/python.eclass,v 1.65 2009/08/15 23:32:58 arfrever Exp $

# @ECLASS: python.eclass
# @MAINTAINER:
# python@gentoo.org
#
# original author: Alastair Tse <liquidx@gentoo.org>
# @BLURB: A Utility Eclass that should be inherited by anything that deals with Python or Python modules.
# @DESCRIPTION:
# Some useful functions for dealing with python.

inherit multilib

if [[ -n "${NEED_PYTHON}" ]] ; then
	PYTHON_ATOM=">=dev-lang/python-${NEED_PYTHON}"
	DEPEND="${PYTHON_ATOM}"
	RDEPEND="${DEPEND}"
else
	PYTHON_ATOM="dev-lang/python"
fi

if ! has "${EAPI:-0}" 0 1 2 || [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
	DEPEND="${DEPEND} >=app-admin/eselect-python-20090804"
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

# @FUNCTION: PYTHON
# @USAGE: [-a|--absolute-path] <Python_ABI="${PYTHON_ABI}">
# @DESCRIPTION:
# Get Python interpreter filename for specified Python ABI. If Python_ABI argument
# is ommitted, then PYTHON_ABI environment variable must be set and is used.
PYTHON() {
	local absolute_path="0" slot=

	while (($#)); do
		case "$1" in
			-a|--absolute-path)
				absolute_path="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option $1"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if [[ "$#" -eq "0" ]]; then
		if [[ -n "${PYTHON_ABI}" ]]; then
			slot="${PYTHON_ABI}"
		else
			die "${FUNCNAME}(): Invalid usage"
		fi
	elif [[ "$#" -eq "1" ]]; then
		slot="$1"
	else
		die "${FUNCNAME}(): Invalid usage"
	fi

	if [[ "${absolute_path}" == "1" ]]; then
		echo -n "${EPREFIX}/usr/bin/python${slot}"
	else
		echo -n "python${slot}"
	fi
}

# @FUNCTION: validate_PYTHON_ABIS
# @DESCRIPTION:
# Make sure PYTHON_ABIS variable has valid value.
validate_PYTHON_ABIS() {
	# Ensure that /usr/bin/python and /usr/bin/python-config are valid.
	if [[ "$(readlink "${EPREFIX}"/usr/bin/python)" != "python-wrapper" ]]; then
		die "${EPREFIX}/usr/bin/python isn't valid symlink"
	fi
	if [[ "$(<"${EPREFIX}"/usr/bin/python-config)" != *"Gentoo python-config wrapper script"* ]]; then
		die "${EPREFIX}/usr/bin/python-config isn't valid script"
	fi

	# USE_${ABI_TYPE^^} and RESTRICT_${ABI_TYPE^^}_ABIS variables hopefully will be included in EAPI >= 4.
	if [[ -z "${PYTHON_ABIS}" ]] && has "${EAPI:-0}" 0 1 2 3; then
		local ABI support_ABI supported_PYTHON_ABIS= restricted_ABI
		PYTHON_ABI_SUPPORTED_VALUES="2.4 2.5 2.6 2.7 3.0 3.1 3.2"
		for ABI in ${USE_PYTHON}; do
			if ! has "${ABI}" ${PYTHON_ABI_SUPPORTED_VALUES}; then
				ewarn "Ignoring unsupported Python ABI '${ABI}'"
				continue
			fi
			support_ABI="1"
			for restricted_ABI in ${RESTRICT_PYTHON_ABIS}; do
				if python -c "from fnmatch import fnmatch; exit(not fnmatch('${ABI}', '${restricted_ABI}'))"; then
					support_ABI="0"
					break
				fi
			done
			[[ "${support_ABI}" == "1" ]] && supported_PYTHON_ABIS+=" ${ABI}"
		done
		export PYTHON_ABIS="${supported_PYTHON_ABIS# }"
	fi

	if [[ -z "${PYTHON_ABIS//[${IFS}]/}" ]]; then
		python_version
		export PYTHON_ABIS="${PYVER}"
	fi
}

# @FUNCTION: python_copy_sources
# @USAGE: [directory]
# @DESCRIPTION:
# Copy unpacked sources of given package for each Python ABI.
python_copy_sources() {
	local dir dirs=() PYTHON_ABI

	if [[ "$#" -eq "0" ]]; then
		if [[ "${WORKDIR}" == "${S}" ]]; then
			die "${FUNCNAME}() cannot be used"
		fi
		dirs="${S}"
	else
		dirs="$@"
	fi

	validate_PYTHON_ABIS
	for PYTHON_ABI in ${PYTHON_ABIS}; do
		for dir in "${dirs[@]}"; do
			cp -lpr "${dir}" "${dir}-${PYTHON_ABI}" > /dev/null || die "Copying of sources failed"
		done
	done
}

# @FUNCTION: python_set_build_dir_symlink
# @USAGE: [directory="build"]
# @DESCRIPTION:
# Create build directory symlink.
python_set_build_dir_symlink() {
	local dir="$1"

	[[ -z "${PYTHON_ABIS}" ]] && die "PYTHON_ABIS variable not set"
	[[ -z "${dir}" ]] && dir="build"

	# Don't delete preexistent directories.
	rm -f "${dir}" || die "Deletion of '${dir}' failed"
	ln -s "${dir}-${PYTHON_ABI}" "${dir}" || die "Creation of '${dir}' directory symlink failed"
}

# @FUNCTION: python_execute_function
# @USAGE: [--action-message message] [-d|--default-function] [--failure-message message] [--nonfatal] [-q|--quiet] [-s|--separate-build-dirs] <function> [arguments]
# @DESCRIPTION:
# Execute specified function for each value of PYTHON_ABIS, optionally passing additional
# arguments. The specified function can use PYTHON_ABI and BUILDDIR variables.
python_execute_function() {
	local action action_message action_message_template= default_function="0" failure_message failure_message_template= function nonfatal="0" PYTHON_ABI quiet="0" separate_build_dirs="0"

	while (($#)); do
		case "$1" in
			--action-message)
				action_message_template="$2"
				shift
				;;
			-d|--default-function)
				default_function="1"
				;;
			--failure-message)
				failure_message_template="$2"
				shift
				;;
			--nonfatal)
				nonfatal="1"
				;;
			-q|--quiet)
				quiet="1"
				;;
			-s|--separate-build-dirs)
				separate_build_dirs="1"
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option $1"
				;;
			*)
				break
				;;
		esac
		shift
	done

	if [[ "${default_function}" == "0" ]]; then
		if [[ "$#" -eq "0" ]]; then
			die "${FUNCNAME}(): Missing function name"
		fi
		function="$1"
		shift
	else
		if [[ "$#" -ne "0" ]]; then
			die "${FUNCNAME}(): --default-function option and function name cannot be specified simultaneously"
		fi
		if has "${EAPI:-0}" 0 1; then
			die "${FUNCNAME}(): --default-function option cannot be used in this EAPI"
		fi

		if [[ "${EBUILD_PHASE}" == "configure" ]]; then
			if has "${EAPI}" 2; then
				python_default_function() {
					econf
				}
			else
				python_default_function() {
					nonfatal econf
				}
			fi
		elif [[ "${EBUILD_PHASE}" == "compile" ]]; then
			python_default_function() {
				emake
			}
		elif [[ "${EBUILD_PHASE}" == "test" ]]; then
			python_default_function() {
				if emake -j1 -n check &> /dev/null; then
					emake -j1 check
				elif emake -j1 -n test &> /dev/null; then
					emake -j1 test
				fi
			}
		elif [[ "${EBUILD_PHASE}" == "install" ]]; then
			python_default_function() {
				emake DESTDIR="${D}" install
			}
		else
			die "${FUNCNAME}(): --default-function option cannot be used in this ebuild phase"
		fi
		function="python_default_function"
	fi

	if [[ "${quiet}" == "0" ]]; then
		[[ "${EBUILD_PHASE}" == "setup" ]] && action="Setting up"
		[[ "${EBUILD_PHASE}" == "unpack" ]] && action="Unpacking"
		[[ "${EBUILD_PHASE}" == "prepare" ]] && action="Preparation"
		[[ "${EBUILD_PHASE}" == "configure" ]] && action="Configuration"
		[[ "${EBUILD_PHASE}" == "compile" ]] && action="Building"
		[[ "${EBUILD_PHASE}" == "test" ]] && action="Testing"
		[[ "${EBUILD_PHASE}" == "install" ]] && action="Installation"
		[[ "${EBUILD_PHASE}" == "preinst" ]] && action="Preinstallation"
		[[ "${EBUILD_PHASE}" == "postinst" ]] && action="Postinstallation"
		[[ "${EBUILD_PHASE}" == "prerm" ]] && action="Preuninstallation"
		[[ "${EBUILD_PHASE}" == "postrm" ]] && action="Postuninstallation"
	fi

	local RED GREEN BLUE NORMAL
	if [[ "${NOCOLOR:-false}" =~ ^(false|no)$ ]]; then
		RED=$'\e[1;31m'
		GREEN=$'\e[1;32m'
		BLUE=$'\e[1;34m'
		NORMAL=$'\e[0m'
	else
		RED=
		GREEN=
		BLUE=
		NORMAL=
	fi

	validate_PYTHON_ABIS
	for PYTHON_ABI in ${PYTHON_ABIS}; do
		if [[ "${quiet}" == "0" ]]; then
			if [[ -n "${action_message_template}" ]]; then
				action_message="$(eval echo -n "${action_message_template}")"
			else
				action_message="${action} of ${CATEGORY}/${PF} with Python ${PYTHON_ABI}..."
			fi
			echo " ${GREEN}*${NORMAL} ${BLUE}${action_message}${NORMAL}"
		fi
		if [[ "${separate_build_dirs}" == "1" ]]; then
			export BUILDDIR="${S}-${PYTHON_ABI}"
			pushd "${BUILDDIR}" > /dev/null || die "pushd failed"
		else
			export BUILDDIR="${S}"
		fi
		if ! EPYTHON="$(PYTHON)" "${function}" "$@"; then
			if [[ -n "${failure_message_template}" ]]; then
				failure_message="$(eval echo -n "${failure_message_template}")"
			else
				failure_message="${action} failed with Python ${PYTHON_ABI} in ${function}() function"
			fi
			if [[ "${nonfatal}" == "1" ]] || has "${PYTHON_ABI}" ${FAILURE_TOLERANT_PYTHON_ABIS}; then
				local ABI enabled_PYTHON_ABIS
				for ABI in ${PYTHON_ABIS}; do
					[[ "${ABI}" != "${PYTHON_ABI}" ]] && enabled_PYTHON_ABIS+=" ${ABI}"
				done
				export PYTHON_ABIS="${enabled_PYTHON_ABIS# }"
				if [[ "${quiet}" == "0" ]]; then
					ewarn "${RED}${failure_message}${NORMAL}"
				fi
			else
				die "${failure_message}"
			fi
		fi
		if [[ "${separate_build_dirs}" == "1" ]]; then
			popd > /dev/null || die "popd failed"
		fi
		unset BUILDDIR
	done

	if [[ "${default_function}" == "1" ]]; then
		unset -f python_default_function
	fi
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
if ! has ${EAPI:-0} 0 1 && [[ -n ${PYTHON_USE_WITH} || -n ${PYTHON_USE_WITH_OR} ]]; then
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

# @FUNCTION: python_get_includedir
# @DESCRIPTION:
# Run without arguments, returns the Python include directory.
python_get_includedir() {
	if [[ -n "${PYTHON_ABI}" ]]; then
		echo "/usr/include/python${PYTHON_ABI}"
	else
		python_version
		echo "/usr/include/python${PYVER}"
	fi
}

# @FUNCTION: python_get_libdir
# @DESCRIPTION:
# Run without arguments, returns the Python library directory.
python_get_libdir() {
	if [[ -n "${PYTHON_ABI}" ]]; then
		echo "${EPREFIX}/usr/$(get_libdir)/python${PYTHON_ABI}"
	else
		python_version
		echo "${EPREFIX}/usr/$(get_libdir)/python${PYVER}"
	fi
}

# @FUNCTION: python_get_sitedir
# @DESCRIPTION:
# Run without arguments, returns the Python site-packages directory.
python_get_sitedir() {
	echo "$(python_get_libdir)/site-packages"
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
# @USAGE: <module>
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
	python -c "import $1" &>/dev/null
}

# @FUNCTION: python_mod_compile
# @USAGE: <file> [more files ...]
# @DESCRIPTION:
# Given filenames, it will pre-compile the module's .pyc and .pyo.
# This function should only be run in pkg_postinst()
#
# Example:
#         python_mod_compile /usr/lib/python2.3/site-packages/pygoogle.py
#
python_mod_compile() {
	if ! has "${EAPI:-0}" 0 1 2 || [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
		die "${FUNCNAME}() cannot be used in this EAPI"
	fi

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
		python${PYVER} -O ${myroot}/usr/$(get_libdir)/python${PYVER}/py_compile.py "${myfiles[@]}" &> /dev/null
	else
		ewarn "No files to compile!"
	fi
}

# @FUNCTION: python_mod_optimize
# @USAGE: [options] [directory|file]
# @DESCRIPTION:
# If no arguments supplied, it will recompile not recursively all modules
# under sys.path (eg. /usr/lib/python2.6, /usr/lib/python2.6/site-packages).
#
# If supplied with arguments, it will recompile all modules recursively
# in the supplied directory.
# This function should only be run in pkg_postinst().
#
# Options passed to this function are passed to compileall.py.
#
# Example:
#         python_mod_optimize ctypesgencore
python_mod_optimize() {
	# Check if phase is pkg_postinst().
	[[ ${EBUILD_PHASE} != "postinst" ]] && die "${FUNCNAME} should only be run in pkg_postinst()"

	if ! has "${EAPI:-0}" 0 1 2 || [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
		local dir file options=() other_dirs=() other_files=() PYTHON_ABI return_code root site_packages_absolute_dirs=() site_packages_dirs=() site_packages_absolute_files=() site_packages_files=()

		# Strip trailing slash from ROOT.
		root="${EROOT%/}"

		# Respect ROOT and options passed to compileall.py.
		while (($#)); do
			case "$1" in
				-l|-f|-q)
					options+=("$1")
					;;
				-d|-x)
					options+=("$1" "$2")
					shift
					;;
				-*)
					ewarn "${FUNCNAME}: Ignoring compile option $1"
					;;
				*)
					if [[ "$1" =~ ^/usr/lib(32|64)?/python[[:digit:]]+\.[[:digit:]]+ ]]; then
						die "${FUNCNAME} doesn't support absolute paths of directories/files in site-packages directories"
					elif [[ "$1" =~ ^/ ]]; then
						if [[ -d "${root}/$1" ]]; then
							other_dirs+=("${root}/$1")
						elif [[ -f "${root}/$1" ]]; then
							other_files+=("${root}/$1")
						elif [[ -e "${root}/$1" ]]; then
							ewarn "'${root}/$1' is not a file or a directory!"
						else
							ewarn "'${root}/$1' doesn't exist!"
						fi
					else
						for PYTHON_ABI in ${PYTHON_ABIS}; do
							if [[ -d "${root}$(python_get_sitedir)/$1" ]]; then
								site_packages_dirs+=("$1")
								break
							elif [[ -f "${root}$(python_get_sitedir)/$1" ]]; then
								site_packages_files+=("$1")
								break
							elif [[ -e "${root}$(python_get_sitedir)/$1" ]]; then
								ewarn "'$1' is not a file or a directory!"
							else
								ewarn "'$1' doesn't exist!"
							fi
						done
					fi
					;;
			esac
			shift
		done

		# Set additional options.
		options+=("-q")

		for PYTHON_ABI in ${PYTHON_ABIS}; do
			if ((${#site_packages_dirs[@]})) || ((${#site_packages_files[@]})); then
				return_code="0"
				ebegin "Compilation and optimization of Python modules for Python ${PYTHON_ABI}"
				if ((${#site_packages_dirs[@]})); then
					for dir in "${site_packages_dirs[@]}"; do
						site_packages_absolute_dirs+=("${root}$(python_get_sitedir)/${dir}")
					done
					"$(PYTHON)" "${root}$(python_get_libdir)/compileall.py" "${options[@]}" "${site_packages_absolute_dirs[@]}" || return_code="1"
					"$(PYTHON)" -O "${root}$(python_get_libdir)/compileall.py" "${options[@]}" "${site_packages_absolute_dirs[@]}" &> /dev/null || return_code="1"
				fi
				if ((${#site_packages_files[@]})); then
					for file in "${site_packages_files[@]}"; do
						site_packages_absolute_files+=("${root}$(python_get_sitedir)/${file}")
					done
					"$(PYTHON)" "${root}$(python_get_libdir)/py_compile.py" "${site_packages_absolute_files[@]}" || return_code="1"
					"$(PYTHON)" -O "${root}$(python_get_libdir)/py_compile.py" "${site_packages_absolute_files[@]}" &> /dev/null || return_code="1"
				fi
				eend "${return_code}"
			fi
			unset site_packages_absolute_dirs site_packages_absolute_files
		done

		# Don't use PYTHON_ABI in next calls to python_get_libdir().
		unset PYTHON_ABI

		if ((${#other_dirs[@]})) || ((${#other_files[@]})); then
			return_code="0"
			ebegin "Compilation and optimization of Python modules placed outside of site-packages directories for Python ${PYVER}..."
			if ((${#other_dirs[@]})); then
				python${PYVER} "${root}$(python_get_libdir)/compileall.py" "${options[@]}" "${other_dirs[@]}" || return_code="1"
				python${PYVER} -O "${root}$(python_get_libdir)/compileall.py" "${options[@]}" "${other_dirs[@]}" &> /dev/null || return_code="1"
			fi
			if ((${#other_files[@]})); then
				python${PYVER} "${root}$(python_get_libdir)/py_compile.py" "${other_files[@]}" || return_code="1"
				python${PYVER} -O "${root}$(python_get_libdir)/py_compile.py" "${other_files[@]}" &> /dev/null || return_code="1"
			fi
			eend "${return_code}"
		fi
	else
		local myroot mydirs=() myfiles=() myopts=() return_code="0"

		# strip trailing slash
		myroot="${EROOT%/}"

		# respect ROOT and options passed to compileall.py
		while (($#)); do
			case "$1" in
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
				"${myopts[@]}" "${mydirs[@]}" || return_code="1"
			python${PYVER} -O \
				"${myroot}"/usr/$(get_libdir)/python${PYVER}/compileall.py \
				"${myopts[@]}" "${mydirs[@]}" &> /dev/null || return_code="1"
		fi

		if ((${#myfiles[@]})); then
			python_mod_compile "${myfiles[@]}"
		fi

		eend "${return_code}"
	fi
}

# @FUNCTION: python_mod_cleanup
# @USAGE: [directory]
# @DESCRIPTION:
# Run with optional arguments, where arguments are directories of
# python modules. If none given, it will look in /usr/lib/python[0-9].[0-9].
#
# It will recursively scan all compiled Python modules in the directories and
# determine if they are orphaned (i.e. their corresponding .py files are missing.)
# If they are, then it will remove their corresponding .pyc and .pyo files.
#
# This function should only be run in pkg_postrm().
python_mod_cleanup() {
	local PYTHON_ABI SEARCH_PATH=() root src_py

	# Check if phase is pkg_postrm().
	[[ ${EBUILD_PHASE} != "postrm" ]] && die "${FUNCNAME} should only be run in pkg_postrm()"

	# Strip trailing slash from ROOT.
	root="${EROOT%/}"

	if (($#)); then
		if ! has "${EAPI:-0}" 0 1 2 || [[ -n "${SUPPORT_PYTHON_ABIS}" ]]; then
			while (($#)); do
				if [[ "$1" =~ ^/usr/lib(32|64)?/python[[:digit:]]+\.[[:digit:]]+ ]]; then
					die "${FUNCNAME} doesn't support absolute paths of directories/files in site-packages directories"
				elif [[ "$1" =~ ^/ ]]; then
					SEARCH_PATH+=("${root}/${1#/}")
				else
					for PYTHON_ABI in ${PYTHON_ABIS}; do
						SEARCH_PATH+=("${root}$(python_get_sitedir)/$1")
					done
				fi
				shift
			done
		else
			SEARCH_PATH=("${@#/}")
			SEARCH_PATH=("${SEARCH_PATH[@]/#/${root}/}")
		fi
	else
		SEARCH_PATH=("${root}"/usr/lib*/python*/site-packages)
	fi

	for path in "${SEARCH_PATH[@]}"; do
		[[ ! -d "${path}" ]] && continue
		einfo "Cleaning orphaned Python bytecode from ${path} .."
		find "${path}" -name '*.py[co]' -print0 | while read -rd ''; do
			src_py="${REPLY%[co]}"
			[[ -f "${src_py}" || (! -f "${src_py}c" && ! -f "${src_py}o") ]] && continue
			einfo "Purging ${src_py}[co]"
			rm -f "${src_py}"[co]
		done

		# Attempt to remove directories that may be empty.
		find "${path}" -type d | sort -r | while read -r dir; do
			rmdir "${dir}" 2>/dev/null && einfo "Removing empty directory ${dir}"
		done
	done
}
