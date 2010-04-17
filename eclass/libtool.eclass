# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/libtool.eclass,v 1.87 2010/04/14 18:14:45 vapier Exp $
#
# Maintainer: base-system@gentoo.org
#
# This eclass patches ltmain.sh distributed with libtoolized packages with the
# relink and portage patch among others
#
# Note, this eclass does not require libtool as it only applies patches to
# generated libtool files.  We do not run the libtoolize program because that
# requires a regeneration of the main autotool files in order to work properly.

DESCRIPTION="Based on the ${ECLASS} eclass"

ELIBTOOL_VERSION="2.0.2"

inherit toolchain-funcs

ELT_PATCH_DIR="${ECLASSDIR}/ELT-patches"
ELT_APPLIED_PATCHES=
ELT_LTMAIN_SH=

#
# Returns all the directories containing ltmain.sh
#
ELT_find_ltmain_sh() {
	local x=
	local dirlist=

	for x in $(find "${S}" -name 'ltmain.sh') ; do
		dirlist="${dirlist} ${x%/*}"
	done

	echo "${dirlist}"
}

#
# See if we can apply $2 on $1, and if so, do it
#
ELT_try_and_apply_patch() {
	local ret=0
	local file=$1
	local patch=$2

	# We only support patchlevel of 0 - why worry if its static patches?
	if patch -p0 --dry-run "${file}" "${patch}" &> "${T}/elibtool.log" ; then
		einfo "  Applying $(basename "$(dirname "${patch}")")-${patch##*/}.patch ..."
		patch -p0 -g0 --no-backup-if-mismatch "${file}" "${patch}" \
			&> "${T}/elibtool.log"
		ret=$?
		export ELT_APPLIED_PATCHES="${ELT_APPLIED_PATCHES} ${patch##*/}"
	else
		ret=1
	fi

	return "${ret}"
}

#
# Get string version of ltmain.sh or ltconfig (passed as $1)
#
ELT_libtool_version() {
	local ltmain_sh=$1
	local version=

	version=$(eval $(grep -e '^[[:space:]]*VERSION=' "${ltmain_sh}"); \
	                 echo "${VERSION}")
	[[ -z ${version} ]] && version="0"

	echo "${version}"
}

#
# Run through the patches in $2 and see if any
# apply to $1 ...
#
ELT_walk_patches() {
	local patch
	local ret=1
	local file=$1
	local patch_set=$2
	local patch_dir="${ELT_PATCH_DIR}/${patch_set}"
	local rem_int_dep=$3

	[[ -z ${patch_set} ]] && return 1
	[[ ! -d ${patch_dir} ]] && return 1

	pushd "${ELT_PATCH_DIR}" >/dev/null

	# Go through the patches in reverse order (newer version to older)
	for patch in $(find "${patch_set}" -maxdepth 1 -type f | LC_ALL=C sort -r) ; do
		# For --remove-internal-dep ...
		if [[ -n ${rem_int_dep} ]] ; then
			# For replace @REM_INT_DEP@ with what was passed
			# to --remove-internal-dep
			local tmp="${T}/$$.rem_int_deps.patch"
			sed -e "s|@REM_INT_DEP@|${rem_int_dep}|g" "${patch}" > "${tmp}"
			patch=${tmp}
		fi

		if ELT_try_and_apply_patch "${file}" "${patch}" ; then
			# Break to unwind w/popd rather than return directly
			ret=0
			break
		fi
	done

	popd >/dev/null
	return ${ret}
}

elibtoolize() {
	local x=
	local y=
	local do_portage="no"
	local do_reversedeps="no"
	local do_only_patches="no"
	local do_uclibc="yes"
	local do_force="no"
	local deptoremove=
	local my_dirlist=
	local elt_patches="install-sh ltmain portage relink max_cmd_len sed test tmp cross as-needed"
	local start_dir=${PWD}

	my_dirlist=$(ELT_find_ltmain_sh)

	for x in "$@" ; do
		case "${x}" in
			"--portage")
				# Only apply portage patch, and don't
				# 'libtoolize --copy --force' if all patches fail.
				do_portage="yes"
				;;
			"--reverse-deps")
				# Apply the reverse-deps patch
				# http://bugzilla.gnome.org/show_bug.cgi?id=75635
				do_reversedeps="yes"
				elt_patches="${elt_patches} fix-relink"
				;;
			"--patch-only")
				# Do not run libtoolize if none of the patches apply ..
				do_only_patches="yes"
				;;
			"^--remove-internal-dep="*)
				# We will replace @REM_INT_DEP@ with what is needed
				# in ELT_walk_patches() ...
				deptoremove=$(echo "${x}" | sed -e 's|--remove-internal-dep=||')

				# Add the patch for this ...
				[[ -n ${deptoremove} ]] && elt_patches="${elt_patches} rem-int-dep"
				;;
			"--shallow")
				# Only patch the ltmain.sh in ${S}
				if [[ -f ${S}/ltmain.sh ]] ; then
					my_dirlist=${S}
				else
					my_dirlist=
				fi
				;;
			"--no-uclibc")
				do_uclibc="no"
				;;
			"--force")
				do_force="yes"
				;;
			*)
				eerror "Invalid elibtoolize option: ${x}"
				die "elibtoolize called with ${x} ??"
		esac
	done

	[[ ${do_uclibc} == "yes" ]] && \
		elt_patches="${elt_patches} uclibc-conf uclibc-ltconf"

	case "${CHOST}" in
		*-aix*)
			elt_patches="${elt_patches} hardcode aixrtl"
		;;
		*-darwin*)
			elt_patches="${elt_patches} darwin-ltconf darwin-ltmain darwin-conf"
		;;
		*-freebsd*)
			elt_patches="${elt_patches} fbsd-conf fbsd-ltconf"
		;;
		*-hpux*)
			elt_patches="${elt_patches} hpux-conf deplibs hc-flag-ld hardcode hardcode-relink relink-prog no-lc"
		;;
		*-irix*)
			elt_patches="${elt_patches} irix-ltmain"
		;;
		*-mint*)
			elt_patches="${elt_patches} mint-conf"
		;;
	esac

	for x in ${my_dirlist} ; do
		local tmp=$(echo "${x}" | sed -e "s|${WORKDIR}||")
		export ELT_APPLIED_PATCHES=
		export ELT_LTMAIN_SH="${x}/ltmain.sh"

		[[ ${do_force} == no && -f ${x}/.elibtoolized ]] && continue

		cd ${x}
		einfo "Running elibtoolize in: $(echo "/${tmp}" | sed -e 's|//|/|g; s|^/||')"

		for y in ${elt_patches} ; do
			local ret=0

			case "${y}" in
				"portage")
					# Stupid test to see if its already applied ...
					if [[ -z $(grep 'We do not want portage' "${x}/ltmain.sh") ]] ; then
						ELT_walk_patches "${x}/ltmain.sh" "${y}"
						ret=$?
					fi
					;;
				"rem-int-dep")
					ELT_walk_patches "${x}/ltmain.sh" "${y}" "${deptoremove}"
					ret=$?
					;;
				"fix-relink")
					# Do not apply if we do not have the relink patch applied ...
					if [[ -n $(grep 'inst_prefix_dir' "${x}/ltmain.sh") ]] ; then
						ELT_walk_patches "${x}/ltmain.sh" "${y}"
						ret=$?
					fi
					;;
				"max_cmd_len")
					# Do not apply if $max_cmd_len is not used ...
					if [[ -n $(grep 'max_cmd_len' "${x}/ltmain.sh") ]] ; then
						ELT_walk_patches "${x}/ltmain.sh" "${y}"
						ret=$?
					fi
					;;
				"as-needed")
					ELT_walk_patches "${x}/ltmain.sh" "${y}"
					ret=$?
					;;
				"uclibc-conf")
					if [[ -e ${x}/configure && \
					      -n $(grep 'Transform linux' "${x}/configure") ]] ; then
						ELT_walk_patches "${x}/configure" "${y}"
						ret=$?
					# ltmain.sh and co might be in a subdirectory ...
					elif [[ ! -e ${x}/configure && -e ${x}/../configure && \
					        -n $(grep 'Transform linux' "${x}/../configure") ]] ; then
						ELT_walk_patches "${x}/../configure" "${y}"
						ret=$?
					fi
					;;
				"uclibc-ltconf")
					# Newer libtoolize clears ltconfig, as not used anymore
					if [[ -s ${x}/ltconfig ]] ; then
						ELT_walk_patches "${x}/ltconfig" "${y}"
						ret=$?
					fi
					;;
				"fbsd-conf")
					if [[ -e ${x}/configure && \
					      -n $(grep 'version_type=freebsd-' "${x}/configure") ]] ; then
						ELT_walk_patches "${x}/configure" "${y}"
						ret=$?
					# ltmain.sh and co might be in a subdirectory ...
					elif [[ ! -e ${x}/configure && -e ${x}/../configure && \
					        -n $(grep 'version_type=freebsd-' "${x}/../configure") ]] ; then
						ELT_walk_patches "${x}/../configure" "${y}"
						ret=$?
					fi
					;;
				"fbsd-ltconf")
					if [[ -s ${x}/ltconfig ]] ; then
						ELT_walk_patches "${x}/ltconfig" "${y}"
						ret=$?
					fi
					;;
				"darwin-conf")
					if [[ -e ${x}/configure && \
					      -n $(grep '&& echo \.so ||' "${x}/configure") ]] ; then
						ELT_walk_patches "${x}/configure" "${y}"
						ret=$?
					# ltmain.sh and co might be in a subdirectory ...
					elif [[ ! -e ${x}/configure && -e ${x}/../configure && \
					        -n $(grep '&& echo \.so ||' "${x}/../configure") ]] ; then
						ELT_walk_patches "${x}/../configure" "${y}"
						ret=$?
					fi
					;;
				"darwin-ltconf")
					# Newer libtoolize clears ltconfig, as not used anymore
					if [[ -s ${x}/ltconfig ]] ; then
						ELT_walk_patches "${x}/ltconfig" "${y}"
						ret=$?
					fi
					;;
				"darwin-ltmain")
					# special case to avoid false positives (failing to apply
					# ltmain.sh path message), newer libtools have this patch
					# built in, so not much to patch around then
					if [[ -e ${x}/ltmain.sh && \
					      -z $(grep 'verstring="-compatibility_version' "${x}/ltmain.sh") ]] ; then
						ELT_walk_patches "${x}/ltmain.sh" "${y}"
						ret=$?
					fi
					;;
				"aixrtl" | "hpux-conf")
					ret=1
					local subret=0
					# apply multiple patches as often as they match
					while [[ $subret -eq 0 ]]; do
						subret=1
						if [[ -e ${x}/configure ]]; then
							ELT_walk_patches "${x}/configure" "${y}"
							subret=$?
						# ltmain.sh and co might be in a subdirectory ...
						elif [[ ! -e ${x}/configure && -e ${x}/../configure ]] ; then
							ELT_walk_patches "${x}/../configure" "${y}"
							subret=$?
						fi
						if [[ $subret -eq 0 ]]; then
							# have at least one patch succeeded.
							ret=0
						fi
					done
					;;
				"mint-conf")
					ret=1
					local subret=1
					if [[ -e ${x}/configure ]]; then
						ELT_walk_patches "${x}/configure" "${y}"
						subret=$?
					# ltmain.sh and co might be in a subdirectory ...
					elif [[ ! -e ${x}/configure && -e ${x}/../configure ]] ; then
						ELT_walk_patches "${x}/../configure" "${y}"
						subret=$?
					fi
					if [[ $subret -eq 0 ]]; then
						# have at least one patch succeeded.
						ret=0
					fi
					;;
				"install-sh")
					ELT_walk_patches "${x}/install-sh" "${y}"
					ret=$?
					;;
				"cross")
					if tc-is-cross-compiler ; then
						ELT_walk_patches "${x}/ltmain.sh" "${y}"
						ret=$?
					fi
					;;
				*)
					ELT_walk_patches "${x}/ltmain.sh" "${y}"
					ret=$?
					;;
			esac

			if [[ ${ret} -ne 0 ]] ; then
				case ${y} in
					"relink")
						local version=$(ELT_libtool_version "${x}/ltmain.sh")
						# Critical patch, but could be applied ...
						# FIXME:  Still need a patch for ltmain.sh > 1.4.0
						if [[ -z $(grep 'inst_prefix_dir' "${x}/ltmain.sh") && \
						      $(VER_to_int "${version}") -ge $(VER_to_int "1.4.0") ]] ; then
							ewarn "  Could not apply relink.patch!"
						fi
						;;
					"portage")
						# Critical patch - for this one we abort, as it can really
						# cause breakage without it applied!
						if [[ ${do_portage} == "yes" ]] ; then
							# Stupid test to see if its already applied ...
							if [[ -z $(grep 'We do not want portage' "${x}/ltmain.sh") ]] ; then
								echo
								eerror "Portage patch requested, but failed to apply!"
								eerror "Please bug azarah or vapier to add proper patch."
								die "Portage patch requested, but failed to apply!"
							fi
						else
							if [[ -n $(grep 'We do not want portage' "${x}/ltmain.sh") ]] ; then
							#	ewarn "  Portage patch seems to be already applied."
							#	ewarn "  Please verify that it is not needed."
								:
							else
							    local version=$( \
									eval $(grep -e '^[[:space:]]*VERSION=' "${x}/ltmain.sh"); \
									echo "${VERSION}")

								echo
								eerror "Portage patch failed to apply (ltmain.sh version ${version})!"
								eerror "Please bug azarah or vapier to add proper patch."
								die "Portage patch failed to apply!"
							fi
							# We do not want to run libtoolize ...
							ELT_APPLIED_PATCHES="portage"
						fi
						;;
					"uclibc-"*)
						[[ ${CHOST} == *"-uclibc" ]] && \
							ewarn "  uClibc patch set '${y}' failed to apply!"
						;;
					"fbsd-"*)
						if [[ ${CHOST} == *"-freebsd"* ]] ; then
							if [[ -z $(grep 'Handle Gentoo/FreeBSD as it was Linux' \
								"${x}/configure" "${x}/../configure" 2>/dev/null) ]]; then
								eerror "  FreeBSD patch set '${y}' failed to apply!"
								die "FreeBSD patch set '${y}' failed to apply!"
							fi
						fi
						;;
					"darwin-"*)
						[[ ${CHOST} == *"-darwin"* ]] && \
							ewarn "  Darwin patch set '${y}' failed to apply!"
						;;
				esac
			fi
		done

		if [[ -z ${ELT_APPLIED_PATCHES} ]] ; then
			if [[ ${do_portage} == "no" && \
				  ${do_reversedeps} == "no" && \
				  ${do_only_patches} == "no" && \
				  ${deptoremove} == "" ]]
			then
				ewarn "Cannot apply any patches, please file a bug about this"
				die
			fi
		fi

		[[ -f ${x}/libtool ]] && rm -f "${x}/libtool"

		>> "${x}/.elibtoolized"
	done

	cd "${start_dir}"
}

uclibctoolize() {
	ewarn "uclibctoolize() is deprecated, please just use elibtoolize()!"
	elibtoolize
}

darwintoolize() {
	ewarn "darwintoolize() is deprecated, please just use elibtoolize()!"
	elibtoolize
}

# char *VER_major(string)
#
#    Return the Major (X of X.Y.Z) version
#
VER_major() {
	[[ -z $1 ]] && return 1

	local VER=$@
	echo "${VER%%[^[:digit:]]*}"
}

# char *VER_minor(string)
#
#    Return the Minor (Y of X.Y.Z) version
#
VER_minor() {
	[[ -z $1 ]] && return 1

	local VER=$@
	VER=${VER#*.}
	echo "${VER%%[^[:digit:]]*}"
}

# char *VER_micro(string)
#
#    Return the Micro (Z of X.Y.Z) version.
#
VER_micro() {
	[[ -z $1 ]] && return 1

	local VER=$@
	VER=${VER#*.*.}
	echo "${VER%%[^[:digit:]]*}"
}

# int VER_to_int(string)
#
#    Convert a string type version (2.4.0) to an int (132096)
#    for easy compairing or versions ...
#
VER_to_int() {
	[[ -z $1 ]] && return 1

	local VER_MAJOR=$(VER_major "$1")
	local VER_MINOR=$(VER_minor "$1")
	local VER_MICRO=$(VER_micro "$1")
	local VER_int=$(( VER_MAJOR * 65536 + VER_MINOR * 256 + VER_MICRO ))

	# We make version 1.0.0 the minimum version we will handle as
	# a sanity check ... if its less, we fail ...
	if [[ ${VER_int} -ge 65536 ]] ; then
		echo "${VER_int}"
		return 0
	fi

	echo 1
	return 1
}
