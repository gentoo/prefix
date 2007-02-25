# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-compiler/eselect-compiler-2.0.0_rc2-r1.ebuild,v 1.6 2007/01/24 14:08:32 genone Exp $

EAPI="prefix"

inherit eutils multilib toolchain-funcs

DESCRIPTION="Utility to configure the active toolchain compiler"
HOMEPAGE="http://www.gentoo.org/"

SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="-*"
IUSE="hardened"

RDEPEND="sys-apps/mktemp"

# We want to verify that compiler profiles exist for our toolchain
pkg_setup() {
	# If not a first time install, verify existence of profiles (bug #139016)
	if [[ -f "${EROOT}/etc/eselect/compiler/selection.conf" ]] ; then

		delete_invalid_profiles

		local abi
		for abi in $(get_all_abis) ; do
			local ctarget=$(get_abi_CHOST ${abi})
			if ! grep -q "^[[:space:]]*ctarget=${ctarget}$" ${EROOT}/etc/eselect/compiler/*.conf ; then
				eerror "We weren't able to find a valid eselect compiler profile for ${abi}."
				eerror "Please do the following to re-emerge gcc, then retry emerging"
				eerror "eselect-compiler:"
				eerror "# emerge -v --oneshot sys-devel/gcc"

				die "Missing eselect-compiler profile for ${abi}"
			fi
		done
	fi
}

pkg_postinst() {
	# For bug #135749
	cp -f "${EROOT}"/usr/libexec/eselect/compiler/compiler-wrapper "${EROOT}"/lib/cpp

	# Activate the profiles
	if [[ -f "${EROOT}/etc/eselect/compiler/selection.conf" ]] ; then
		eselect compiler update
	elif has_version sys-devel/gcc; then # (bug #139830)
		ewarn "This looks like the first time you are installing eselect-compiler.  We are"
		ewarn "activating toolchain profiles for the CTARGETs needed by your portage"
		ewarn "profile.  You should have profiles installed from compilers that you emerged"
		ewarn "after October, 2005.  If a compiler you have installed is missing an"
		ewarn "eselect-compiler profile, you can either re-emerge the compiler, create the"
		ewarn "profile yourself, or you can migrate profiles from gcc-config-1.x by doing:"
		ewarn "# eselect compiler migrate"
		ewarn
		ewarn "Note that if you use the migration tool, your current profiles will be"
		ewarn "replaced, so you should backup the data in /etc/eselect/compiler first."
		echo
		elog "The following profiles have been activated.  If an incorrect profile is"
		elog "chosen or an error is reported, please use 'eselect compiler set' to"
		elog "manually choose it"

		local abi
		for abi in $(get_all_abis) ; do
			local ctarget=$(get_abi_CHOST ${abi})
			local extra_options=""

			if [[ ${abi} == ${DEFAULT_ABI} ]] ; then
				extra_options="-n"
			fi

			local spec
			if use hardened ; then
				spec="hardened"
			else
				spec="vanilla"
			fi

			local isset=0
			local tuple
			for tuple in "${CHOST}" "${CTARGET}" "${ctarget}" ; do
				local version
				for version in "$(gcc-fullversion)" ; do
					local profile
					for profile in "${abi}-${spec}" "${spec}" "${abi}-default" "default" "${abi}-vanilla" "vanilla" ; do
						if eselect compiler set ${tuple}-${version}/${profile} ${extra_options} &> /dev/null ; then
							einfo "${abi}: ${tuple}-${version}/${profile}"

							isset=1
							break
						fi
					done
					[[ ${isset} == 1 ]] && break
				done
				[[ ${isset} == 1 ]] && break
			done

			if [[ ${isset} == 0 ]] ; then
				eerror "${abi}: Unable to determine an appropriate profile.  Please set manually."
			fi
		done
	else
		ewarn "Note; eselect-compiler will not be operational until you install a compiler."
	fi

	local file
	local resource_profile=0
	for file in ${EROOT}/etc/env.d/05gcc* ; do
		if [[ -f ${file} ]] ; then
			ewarn "Removing env.d entry which was used by gcc-config:"
			ewarn "    ${file}"

			rm -f ${file}

			resource_profile=1
		fi
	done

	if [[ ${resource_profile} == 1 ]] ; then
		echo
		ewarn "You should source /etc/profile in your open shells."

	fi
}

src_unpack() {
	unpack ${A}
	cd ${S}
	epatch ${FILESDIR}/eselect-compiler-2.0.0_rc2-bug135688.patch
}

src_install() {
	dodoc README
	make DESTDIR="${D}" install || die

	doenvd ${FILESDIR}/25eselect-compiler

	# This is installed by sys-devel/gcc-config
	rm ${ED}/usr/bin/gcc-config
}

# The profiles are protected by CONFIG_PROJECT until eselect-compiler is installed, so we need to clean out
# the invalid profiles when eselect-compiler is first installed
delete_invalid_profiles() {
	# Some toolchain.eclass installed confs had some bugs in them. We
	# could just use sed to update them, but then portage won't remove
	# them automatically on unmerge.
	local file
	for file in $(grep "^[[:space:]]*chost=" ${EROOT}/etc/eselect/compiler/*.conf | cut -f1 -d:)  ; do
		rm ${file}
	done
	for file in $(grep "^[[:space:]]*spec=" ${EROOT}/etc/eselect/compiler/*.conf | cut -f1 -d:)  ; do
		rm ${file}
	done

	# First we need to clean out /etc/eselect/compiler as there may
	# be some profiles in there which were not unmerged with gcc.
	local item
	for item in $(grep "^[[:space:]]*binpath=" ${EROOT}/etc/eselect/compiler/*.conf | sed 's/:.*binpath=/:/') ; do
		local file=${item%:*}
		local binpath=${item#*:}
		[[ -d ${binpath} ]] || rm ${file}
	done
}

