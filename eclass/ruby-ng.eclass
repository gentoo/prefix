# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/ruby-ng.eclass,v 1.21 2010/07/08 04:00:57 flameeyes Exp $
#
# @ECLASS: ruby-ng.eclass
# @MAINTAINER:
# Ruby herd <ruby@gentoo.org>
#
# Author: Diego E. Pettenò <flameeyes@gentoo.org>
#
# Author: Alex Legler <a3li@gentoo.org>
#
# Author: Hans de Graaff <graaff@gentoo.org>
#
# @BLURB: An eclass for installing Ruby packages with proper support for multiple Ruby slots.
# @DESCRIPTION:
# The Ruby eclass is designed to allow an easier installation of Ruby packages
# and their incorporation into the Gentoo Linux system.
#
# Currently available targets are:
#  * ruby18 - Ruby (MRI) 1.8.x
#  * ruby19 - Ruby (MRI) 1.9.x
#  * ree18  - Ruby Enterprise Edition 1.8.x
#  * jruby  - JRuby
#
# This eclass does not define the implementation of the configure,
# compile, test, or install phases. Instead, the default phases are
# used.  Specific implementations of these phases can be provided in
# the ebuild either to be run for each Ruby implementation, or for all
# Ruby implementations, as follows:
#
#  * each_ruby_configure
#  * all_ruby_configure

# @ECLASS-VARIABLE: USE_RUBY
# @DESCRIPTION:
# This variable contains a space separated list of targets (see above) a package
# is compatible to. It must be set before the `inherit' call. There is no
# default. All ebuilds are expected to set this variable.

# @ECLASS-VARIABLE: RUBY_PATCHES
# @DESCRIPTION:
# A String or Array of filenames of patches to apply to all implementations.

# @ECLASS-VARIABLE: RUBY_OPTIONAL
# @DESCRIPTION:
# Set the value to "yes" to make the dependency on a Ruby interpreter optional.

inherit eutils toolchain-funcs

EXPORT_FUNCTIONS src_unpack src_prepare src_configure src_compile src_test src_install pkg_setup

case ${EAPI} in
	0|1)
		die "Unsupported EAPI=${EAPI} (too old) for ruby-ng.eclass" ;;
	2) ;;
	*)
		die "Unknown EAPI=${EAPI} for ruby-ng.eclass"
esac

# @FUNCTION: ruby_implementation_depend
# @USAGE: target [comparator [version]]
# @RETURN: Package atom of a Ruby implementation to be used in dependencies.
# @DESCRIPTION:
# This function returns the formal package atom for a Ruby implementation.
#
# `target' has to be one of the valid values for USE_RUBY (see above)
#
# Set `comparator' and `version' to include a comparator (=, >=, etc.) and a
# version string to the returned string
ruby_implementation_depend() {
	local rubypn=
	local rubyslot=

	case $1 in
		ruby18)
			rubypn="dev-lang/ruby"
			rubyslot=":1.8"
			;;
		ruby19)
			rubypn="dev-lang/ruby"
			rubyslot=":1.9"
			;;
		ree18)
			rubypn="dev-lang/ruby-enterprise"
			rubyslot=":1.8"
			;;
		jruby)
			rubypn="dev-java/jruby"
			rubyslot=""
			;;
		*) die "$1: unknown Ruby implementation"
	esac

	echo "$2${rubypn}$3${rubyslot}"
}

# @FUNCTION: ruby_samelib
# @RETURN: use flag string with current ruby implementations
# @DESCRIPTION:
# Convenience function to output the use dependency part of a
# dependency. Used as a building block for ruby_add_rdepend() and
# ruby_add_bdepend(), but may also be useful in an ebuild to specify
# more complex dependencies.
ruby_samelib() {
	local res=
	for _ruby_implementation in $USE_RUBY; do
		has -${_ruby_implementation} $@ || \
			res="${res}ruby_targets_${_ruby_implementation}?,"
	done

	echo "[${res%,}]"
}

_ruby_atoms_samelib_generic() {
	eshopts_push -o noglob
	echo "RUBYTARGET? ("
	for token in $*; do
		case "$token" in
			"||" | "(" | ")" | *"?")
				echo "${token}" ;;
			*])
				echo "${token%[*}[RUBYTARGET,${token/*[}" ;;
			*)
				echo "${token}[RUBYTARGET]" ;;
		esac
	done
	echo ")"
	eshopts_pop
}

_ruby_atoms_samelib() {
	local atoms=$(_ruby_atoms_samelib_generic "$*")

	for _ruby_implementation in $USE_RUBY; do
		echo "${atoms//RUBYTARGET/ruby_targets_${_ruby_implementation}}"
	done
}

_ruby_wrap_conditions() {
	local conditions="$1"
	local atoms="$2"

	for condition in $conditions; do
		atoms="${condition}? ( ${atoms} )"
	done

	echo "$atoms"
}

# @FUNCTION: ruby_add_rdepend
# @USAGE: dependencies
# @DESCRIPTION:
# Adds the specified dependencies, with use condition(s) to RDEPEND,
# taking the current set of ruby targets into account. This makes sure
# that all ruby dependencies of the package are installed for the same
# ruby targets. Use this function for all ruby dependencies instead of
# setting RDEPEND yourself. The list of atoms uses the same syntax as
# normal dependencies.
#
# Note: runtime dependencies are also added as build-time test
# dependencies.
ruby_add_rdepend() {
	case $# in
		1) ;;
		2)
			[[ "${GENTOO_DEV}" == "yes" ]] && eqawarn "You can now use the usual syntax in ruby_add_rdepend for $CATEGORY/$PF"
			ruby_add_rdepend "$(_ruby_wrap_conditions "$1" "$2")"
			return
			;;
		*)
			die "bad number of arguments to $0"
			;;
	esac

	local dependency=$(_ruby_atoms_samelib "$1")

	RDEPEND="${RDEPEND} $dependency"

	# Add the dependency as a test-dependency since we're going to
	# execute the code during test phase.
	DEPEND="${DEPEND} test? ( ${dependency} )"
	hasq test "$IUSE" || IUSE="${IUSE} test"
}

# @FUNCTION: ruby_add_bdepend
# @USAGE: dependencies
# @DESCRIPTION:
# Adds the specified dependencies, with use condition(s) to DEPEND,
# taking the current set of ruby targets into account. This makes sure
# that all ruby dependencies of the package are installed for the same
# ruby targets. Use this function for all ruby dependencies instead of
# setting DEPEND yourself. The list of atoms uses the same syntax as
# normal dependencies.
ruby_add_bdepend() {
	case $# in
		1) ;;
		2)
			[[ "${GENTOO_DEV}" == "yes" ]] && eqawarn "You can now use the usual syntax in ruby_add_bdepend for $CATEGORY/$PF"
			ruby_add_bdepend "$(_ruby_wrap_conditions "$1" "$2")"
			return
			;;
		*)
			die "bad number of arguments to $0"
			;;
	esac

	local dependency=$(_ruby_atoms_samelib "$1")

	DEPEND="${DEPEND} $dependency"
	RDEPEND="${RDEPEND}"
}

for _ruby_implementation in $USE_RUBY; do
	IUSE="${IUSE} ruby_targets_${_ruby_implementation}"

	# If you specify RUBY_OPTIONAL you also need to take care of
	# ruby useflag and dependency.
	if [[ ${RUBY_OPTIONAL} != "yes" ]]; then
		DEPEND="${DEPEND} ruby_targets_${_ruby_implementation}? ( $(ruby_implementation_depend $_ruby_implementation) )"
		RDEPEND="${RDEPEND} ruby_targets_${_ruby_implementation}? ( $(ruby_implementation_depend $_ruby_implementation) )"
	fi
done

_ruby_invoke_environment() {
	old_S=${S}
	sub_S=${S#${WORKDIR}/}

	# Special case, for the always-lovely GitHub fetches. With this,
	# we allow the star glob to just expand to whatever directory it's
	# called.
	if [[ ${sub_S} = *"*" ]]; then
		pushd "${WORKDIR}"/all &>/dev/null
		sub_S=$(eval ls -d ${sub_S} 2>/dev/null)
		popd &>/dev/null
	fi

	environment=$1; shift

	my_WORKDIR="${WORKDIR}"/${environment}
	S="${my_WORKDIR}"/"${sub_S}"

	if [[ -d "${S}" ]]; then
		pushd "$S" &>/dev/null
	elif [[ -d "${my_WORKDIR}" ]]; then
		pushd "${my_WORKDIR}" &>/dev/null
	else
		pushd "${WORKDIR}" &>/dev/null
	fi

	ebegin "Running ${_PHASE:-${EBUILD_PHASE}} phase for $environment"
	"$@"
	popd &>/dev/null

	S=${old_S}
}

_ruby_each_implementation() {
	local invoked=no
	for _ruby_implementation in ${USE_RUBY}; do
		# only proceed if it's requested
		use ruby_targets_${_ruby_implementation} || continue

		local _ruby_name=$_ruby_implementation

		# Add all USE_RUBY values where the flag name diverts from the binary here
		case $_ruby_implementation in
			ree18)
				_ruby_name=rubyee18
				;;
		esac

		RUBY=$(type -p $_ruby_name 2>/dev/null)
		invoked=yes

		if [[ -n "$1" ]]; then
			_ruby_invoke_environment $_ruby_implementation "$@"
		fi

		unset RUBY
	done

	[[ ${invoked} == "no" ]] && die "You need to select at least one Ruby implementation by setting RUBY_TARGETS in /etc/make.conf."
}

# @FUNCTION: ruby-ng_pkg_setup
# @DESCRIPTION:
# Check whether at least one ruby target implementation is present.
ruby-ng_pkg_setup() {
	# This only checks that at least one implementation is present
	# before doing anything; by leaving the parameters empty we know
	# it's a special case.
	_ruby_each_implementation
}

# @FUNCTION: ruby-ng_src_unpack
# @DESCRIPTION:
# Unpack the source archive.
ruby-ng_src_unpack() {
	mkdir "${WORKDIR}"/all
	pushd "${WORKDIR}"/all &>/dev/null

	# We don't support an each-unpack, it's either all or nothing!
	if type all_ruby_unpack &>/dev/null; then
		_ruby_invoke_environment all all_ruby_unpack
	else
		[[ -n ${A} ]] && unpack ${A}
	fi

	popd &>/dev/null
}

_ruby_apply_patches() {
	for patch in "${RUBY_PATCHES[@]}"; do
		if [ -f "${patch}" ]; then
			epatch "${patch}"
		elif [ -f "${FILESDIR}/${patch}" ]; then
			epatch "${FILESDIR}/${patch}"
		else
			die "Cannot find patch ${patch}"
		fi
	done

	# This is a special case: instead of executing just in the special
	# "all" environment, this will actually copy the effects on _all_
	# the other environments, and is thus executed before the copy
	type all_ruby_prepare &>/dev/null && all_ruby_prepare
}

_ruby_source_copy() {
	# Until we actually find a reason not to, we use hardlinks, this
	# should reduce the amount of disk space that is wasted by this.
	cp -prl all ${_ruby_implementation} \
		|| die "Unable to copy ${_ruby_implementation} environment"
}

# @FUNCTION: ruby-ng_src_prepare
# @DESCRIPTION:
# Apply patches and prepare versions for each ruby target
# implementation. Also carry out common clean up tasks.
ruby-ng_src_prepare() {
	# Way too many Ruby packages are prepared on OSX without removing
	# the extra data forks, we do it here to avoid repeating it for
	# almost every other ebuild.
	find . -name '._*' -delete

	_ruby_invoke_environment all _ruby_apply_patches

	_PHASE="source copy" \
		_ruby_each_implementation _ruby_source_copy

	if type each_ruby_prepare &>/dev/null; then
		_ruby_each_implementation each_ruby_prepare
	fi
}

# @FUNCTION: ruby-ng_src_configure
# @DESCRIPTION:
# Configure the package.
ruby-ng_src_configure() {
	if type each_ruby_configure &>/dev/null; then
		_ruby_each_implementation each_ruby_configure
	fi

	type all_ruby_configure &>/dev/null && \
		_ruby_invoke_environment all all_ruby_configure
}

# @FUNCTION: ruby-ng_src_compile
# @DESCRIPTION:
# Compile the package.
ruby-ng_src_compile() {
	if type each_ruby_compile &>/dev/null; then
		_ruby_each_implementation each_ruby_compile
	fi

	type all_ruby_compile &>/dev/null && \
		_ruby_invoke_environment all all_ruby_compile
}

# @FUNCTION: ruby-ng_src_test
# @DESCRIPTION:
# Run tests for the package.
ruby-ng_src_test() {
	if type each_ruby_test &>/dev/null; then
		_ruby_each_implementation each_ruby_test
	fi

	type all_ruby_test &>/dev/null && \
		_ruby_invoke_environment all all_ruby_test
}

_each_ruby_check_install() {
	local libruby_basename=$(${RUBY} -rrbconfig -e 'puts Config::CONFIG["LIBRUBY_SO"]')
	if [[ ${CHOST} == *-darwin ]] ; then
		# we have a Mach-O object here
		local libruby_soname=$(scanmacho -qS "${EPREFIX}/usr/$(get_libdir)/${libruby_basename}" | awk '{ print $1 }')
		# install_names are absolute
		libruby_soname=${libruby_soname##*/}
	else
		local libruby_soname=$(scanelf -qS "${EPREFIX}/usr/$(get_libdir)/${libruby_basename}" | awk '{ print $1 }')
	fi
	local sitedir=$(${RUBY} -rrbconfig -e 'puts Config::CONFIG["sitedir"]')
	local sitelibdir=$(${RUBY} -rrbconfig -e 'puts Config::CONFIG["sitelibdir"]')

	# Look for wrong files in sitedir
	if [[ -d "${D}${sitedir}" ]]; then
		local f=$(find "${D}${sitedir}" -mindepth 1 -maxdepth 1 -not -wholename "${D}${sitelibdir}")
		if [[ -n ${f} ]]; then
			eerror "Found files in sitedir, outsite sitelibdir:"
			eerror "${f}"
			die "Misplaced files in sitedir"
		fi
	fi

	# The current implementation lacks libruby (i.e.: jruby)
	[[ -z ${libruby_soname} ]] && return 0

	if [[ ${CHOST} == *-darwin* ]] ; then
		scanmacho -qnR "${D}${sitedir}" \
			| fgrep -v "${libruby_soname}" \
			> "${T}"/ruby-ng-${_ruby_implementation}-mislink.log
	else
		scanelf -qnR "${D}${sitedir}" \
			| fgrep -v "${libruby_soname}" \
			> "${T}"/ruby-ng-${_ruby_implementation}-mislink.log
	fi

	if [[ -s "${T}"/ruby-ng-${_ruby_implementation}-mislink.log ]]; then
		ewarn "Extensions installed for ${_ruby_implementation} with missing links to ${libruby_soname}"
		ewarn $(< "${T}"/ruby-ng-${_ruby_implementation}-mislink.log )
		die "Missing links to ${libruby_soname}"
	fi
}

# @FUNCTION: ruby-ng_src_install
# @DESCRIPTION:
# Install the package for each ruby target implementation.
ruby-ng_src_install() {
	if type each_ruby_install &>/dev/null; then
		_ruby_each_implementation each_ruby_install
	fi

	type all_ruby_install &>/dev/null && \
		_ruby_invoke_environment all all_ruby_install

	_PHASE="check install" \
		_ruby_each_implementation _each_ruby_check_install
}

# @FUNCTION: ruby_rbconfig_value
# @USAGE: rbconfig item
# @RETURN: Returns the value of the given rbconfig item of the Ruby interpreter in ${RUBY}.
ruby_rbconfig_value() {
	echo $(${RUBY} -rrbconfig -e "puts Config::CONFIG['$1']")
}

# @FUNCTION: doruby
# @USAGE: file [file...]
# @DESCRIPTION:
# Installs the specified file(s) into the sitelibdir of the Ruby interpreter in ${RUBY}.
doruby() {
	[[ -z ${RUBY} ]] && die "\$RUBY is not set"
	( # don't want to pollute calling env
		sitelibdir=$(ruby_rbconfig_value 'sitelibdir')
		insinto ${sitelibdir#${EPREFIX}}
		insopts -m 0644
		doins "$@"
	) || die "failed to install $@"
}

# @FUNCTION: ruby_get_libruby
# @RETURN: The location of libruby*.so belonging to the Ruby interpreter in ${RUBY}.
ruby_get_libruby() {
	${RUBY} -rrbconfig -e 'puts File.join(Config::CONFIG["libdir"], Config::CONFIG["LIBRUBY"])'
}

# @FUNCTION: ruby_get_hdrdir
# @RETURN: The location of the header files belonging to the Ruby interpreter in ${RUBY}.
ruby_get_hdrdir() {
	local rubyhdrdir=$(ruby_rbconfig_value 'rubyhdrdir')

	if [[ "${rubyhdrdir}" = "nil" ]] ; then
		rubyhdrdir=$(ruby_rbconfig_value 'archdir')
	fi

	echo "${rubyhdrdir}"
}

# @FUNCTION: ruby_get_version
# @RETURN: The version of the Ruby interpreter in ${RUBY}, or what 'ruby' points to.
ruby_get_version() {
	local ruby=${RUBY:-$(type -p ruby 2>/dev/null)}

	echo $(${ruby} -e 'puts RUBY_VERSION')
}

# @FUNCTION: ruby_get_implementation
# @RETURN: The implementation of the Ruby interpreter in ${RUBY}, or what 'ruby' points to.
ruby_get_implementation() {
	local ruby=${RUBY:-$(type -p ruby 2>/dev/null)}

	case $(${ruby} --version) in
		*Enterprise*)
			echo "ree"
			;;
		*jruby*)
			echo "jruby"
			;;
		*)
			echo "mri"
			;;
	esac
}
