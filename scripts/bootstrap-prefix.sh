#!/usr/bin/env bash
# Copyright 2006-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

trap 'exit 1' TERM KILL INT QUIT ABRT

# RAP (libc) mode is triggered on Linux kernel and glibc.
is-rap() { [[ ${PREFIX_DISABLE_RAP} != "yes" && ${CHOST} = *linux-gnu* ]]; }
rapx() { is-rap && echo $1 || echo $2; }

## Functions Start Here

estatus() {
	# this can give some garbage in the logs, but it shouldn't be too
	# disturbing -- if it works, it makes it easy to see where we are in
	# the bootstrap from the terminal status line (usually the window
	# name)
	printf '\033]2;'"$*"'\007'
}

eerror() { estatus $*; echo "!!! $*" 1>&2; }
einfo() { echo "* $*"; }
v() { echo "$@"; "$@"; }

econf() {
	estatus "stage1: configuring ${PWD##*/}"
	v ${CONFIG_SHELL} ./configure \
		--host=${CHOST} \
		--prefix="${ROOT}"/tmp/usr \
		--mandir="${ROOT}"/tmp/usr/share/man \
		--infodir="${ROOT}"/tmp/usr/share/info \
		--datadir="${ROOT}"/tmp/usr/share \
		--sysconfdir="${ROOT}"/tmp/etc \
		--localstatedir="${ROOT}"/tmp/var/lib \
		--build=${CHOST} \
		"$@" || return 1
}

emake() {
	[[ $* == *install* ]] \
		&& estatus "stage1: installing ${PWD##*/}" \
		|| estatus "stage1: building ${PWD##*/}"
	v ${MAKE} ${MAKEOPTS} "$@" || return 1
}

efetch() {
	if [[ ! -e ${DISTDIR}/${1##*/} ]] ; then
	  	if [[ ${OFFLINE_MODE} ]]; then
		  echo "I need ${1##*/} from $1 in $DISTDIR, can you give it to me?"
		  read
		  [[ -e ${DISTDIR}/${1##*/} ]] && return 0
		  # Give fetch a try
		fi

		if [[ -z ${FETCH_COMMAND} ]] ; then
			# Try to find a download manager, we only deal with wget,
			# curl, FreeBSD's fetch and ftp.
			if [[ x$(type -t wget) == "xfile" ]] ; then
				FETCH_COMMAND="wget"
				[[ $(wget -h) == *"--no-check-certificate"* ]] \
					&& FETCH_COMMAND+=" --no-check-certificate"
			elif [[ x$(type -t curl) == "xfile" ]] ; then
				FETCH_COMMAND="curl -f -L -O"
			elif [[ x$(type -t fetch) == "xfile" ]] ; then
				FETCH_COMMAND="fetch"
			elif [[ x$(type -t ftp) == "xfile" ]] &&
				 [[ ${CHOST} != *-cygwin* || \
				 ! $(type -P ftp) -ef $(cygpath -S)/ftp ]] ; then
				FETCH_COMMAND="ftp"
			else
				eerror "no suitable download manager found!"
				eerror "tried: wget, curl, fetch and ftp"
				eerror "could not download ${1##*/}"
				exit 1
			fi
		fi

		mkdir -p "${DISTDIR}" >& /dev/null
		einfo "Fetching ${1##*/}"
		estatus "stage1: fetching ${1##*/}"
		pushd "${DISTDIR}" > /dev/null

		# Try for mirrors first, fall back to distfiles, then try given location
		local locs=( )
		local loc
		for loc in ${GENTOO_MIRRORS} ${DISTFILES_G_O} ${DISTFILES_PFX}; do
			locs=(
				"${locs[@]}"
				"${loc}/distfiles/${1##*/}"
			)
		done
		locs=( "${locs[@]}" "$1" )

		for loc in "${locs[@]}" ; do
			v ${FETCH_COMMAND} "${loc}" < /dev/null
			[[ -f ${1##*/} ]] && break
		done
		if [[ ! -f ${1##*/} ]] ; then
			eerror "downloading ${1} failed!"
			return 1
		fi
		popd > /dev/null
	fi
	return 0
}

configure_cflags() {
	export CPPFLAGS="-I${ROOT}/tmp/usr/include"

	case ${CHOST} in
		*-darwin*)
			export LDFLAGS="-Wl,-search_paths_first -L${ROOT}/tmp/usr/lib"
			;;
		*-solaris*)
			export LDFLAGS="-L${ROOT}/tmp/usr/lib -R${ROOT}/tmp/usr/lib"
			;;
		i586-pc-winnt* | *-pc-cygwin*)
			export LDFLAGS="-L${ROOT}/tmp/usr/lib"
			;;
		*)
			export LDFLAGS="-L${ROOT}/tmp/usr/lib -Wl,-rpath=${ROOT}/tmp/usr/lib"
			;;
	esac

	case ${CHOST} in
		# note: we need CXX for binutils-apple which' ld is c++
		*64-apple* | sparcv9-*-solaris* | x86_64-*-solaris*)
			export CC="${CC-gcc} -m64"
			export CXX="${CXX-g++} -m64"
			export HOSTCC="${CC}"
			;;
		i*86-apple-darwin1*)
			export CC="${CC-gcc} -m32"
			export CXX="${CXX-g++} -m32"
			export HOSTCC="${CC}"
			;;
		i*86-pc-linux-gnu)
			if [[ $(${CC} -dumpspecs | grep -A1 multilib_default) != *m32 ]]; then
				export CC="${CC-gcc} -m32"
				export CXX="${CXX-g++} -m32"
			fi
			;;
	esac

	# point possible host pkg-config to stage2 files
	export PKG_CONFIG_PATH=${ROOT}/tmp/usr/lib/pkgconfig
}

configure_toolchain() {
	linker="sys-devel/binutils"
	local gcc_deps="dev-libs/gmp dev-libs/mpfr dev-libs/mpc"
	compiler="${gcc_deps} sys-devel/gcc-config sys-devel/gcc"
	compiler_stage1="${gcc_deps} sys-devel/gcc-config"
	compiler_type="gcc"
	case ${CHOST} in
	*-cygwin*)
	  # not supported in gcc-4.7 yet, easy enough to install g++
	  # Cygwin patches come as .zip from github
	  compiler_stage1+=" app-arch/unzip sys-devel/gcc"
	  ;;
	*-darwin*)
	  # handled below
	  ;;
	*-freebsd* | *-openbsd*)
	  # comes with clang, handled below
	  ;;
	*)
	  # The host may not have a functioning c++ toolchain, so use a
	  # stage1 compiler that can build with C only.
	  # But gcc-4.7 fails to build with gcc-5.4, so we check for
	  # >gcc-4.7, as anything newer provides c++ anyway (#619542).
	  # gcc-4.7 is the last version not to require a c++ compiler to
	  # build
	  eval $( (gcc -E - | grep compiler_stage1) <<-EOP
		#if defined(__GNUC__) && (__GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ > 7))
		  compiler_stage1+=" sys-devel/gcc"
		#elif defined(__GNUC__) && __GNUC__ >= 4
		  compiler_stage1+=" <sys-devel/gcc-4.8"
		#else
		  compiler_stage1+=" <sys-devel/gcc-4.7"
		#endif
		EOP
	  )
	esac

	CC=gcc
	CXX=g++

	case ${CHOST}:${DARWIN_USE_GCC} in
		*darwin*:1)
			einfo "Triggering Darwin with GCC toolchain"
			compiler_stage1+=" sys-apps/darwin-miscutils"
			local ccvers="$(unset CHOST; /usr/bin/gcc --version 2>/dev/null)"
			local isgcc=
			case "${ccvers}" in
				*"(GCC) 4.2.1 "*)
					linker="=sys-devel/binutils-apple-3.2.6"
					isgcc=true
					;;
				*"(GCC) 4.0.1 "*)
					linker="=sys-devel/binutils-apple-3.2.6"
					# upgrade to 4.2.1 first
					compiler_stage1+="
						sys-devel/gcc-apple
						=sys-devel/binutils-apple-3.2.6"
					isgcc=true
					;;
				*"Apple clang version "*|*"Apple LLVM version "*)
					# recent binutils-apple are hard to build (C++11
					# features, and cmake build system) so avoid going
					# there, the system ld is good enough to bring us to
					# stage3, after which the @system set will take care of
					# the rest
					linker=sys-devel/native-cctools
					;;
				*)
					eerror "unknown compiler: ${ccvers}"
					return 1
					;;
			esac
			if [[ ${isgcc} == true ]] ; then
				# current compiler (gcc-11) requires C++11, which is
				# available since 4.8, so need to bootstrap with <11
				compiler_stage1+=" <sys-devel/gcc-11"
				compiler="${compiler%sys-devel/gcc} <sys-devel/gcc-11"
			else
				# assume LLVM/Clang has C++11 support
				compiler_stage1+=" sys-devel/gcc"
			fi
			;;
		*-darwin*)
			einfo "Triggering Darwin with LLVM/Clang toolchain"
			# for compilers choice, see bug:
			# https://bugs.gentoo.org/show_bug.cgi?id=538366
			compiler_stage1="sys-apps/darwin-miscutils"
			compiler_type="clang"
			local ccvers="$(unset CHOST; /usr/bin/gcc --version 2>/dev/null)"
			local llvm_deps="dev-util/ninja"
			case "${ccvers}" in
				*"Apple clang version "*|*"Apple LLVM version "*)
					# this is Clang, recent enough to compile recent clang
					compiler_stage1+="
						${llvm_deps}
						sys-libs/libcxxabi
						sys-libs/libcxx
						sys-devel/llvm
						sys-devel/clang
					"
					CC=clang
					CXX=clang++
					# avoid going through hoops and deps for
					# binutils-apple, rely on the host-installed ld to
					# build a compiler, we'll pull in binutils-apple
					# from system set
					linker=sys-devel/native-cctools
					;;
				*)
					eerror "unknown/unsupported compiler"
					return 1
					;;
			esac

			compiler="
				dev-libs/libffi
				${llvm_deps}
				sys-libs/libcxxabi
				sys-libs/libcxx
				sys-devel/llvm
				sys-devel/clang"
			;;
		*-freebsd* | *-openbsd*)
			CC=clang
			CXX=clang++
			# TODO: target clang toolchain someday?
			;;
		*-solaris*)
			local ccvers="$(unset CHOST; gcc --version 2>/dev/null)"
			case "${ccvers}" in
				*"gcc (GCC) 3.4.3"*)
					# host compiler doesn't cope with the asm introduced
					# in mpfr-4, so force using an older one during
					# bootstrap for this target
					compiler_stage1=${compiler_stage1/" dev-libs/mpfr "/" <dev-libs/mpfr-4 "}
					;;
			esac
			local nmout=$(nm -B 2>&1)
			case "${nmout}" in
				*/dev/null*)  :                            ;;  # apparently GNU
				*)            export NM="$(type -P nm) -p" ;;  # Solaris nm
			esac
			;;
		*-linux*)
			is-rap && einfo "Triggering Linux RAP bootstrap"
			;;
	esac

	return 0
}

bootstrap_setup() {
	local profile=""
	einfo "Setting up some guessed defaults"

	# 2.6.32.1 -> 2*256^3 + 6*256^2 + 32 * 256 + 1 = 33955841
	kver() { uname -r|cut -d\- -f1|awk -F. '{for (i=1; i<=NF; i++){s+=lshift($i,(4-i)*8)};print s}'; }
	# >=glibc-2.20 requires >=linux-2.6.32.
	profile-kernel() {
		if [[ $(kver) -ge 50462720 ]] ; then # 3.2
			echo kernel-3.2+
		elif [[ $(kver) -ge 33955840 ]] ; then # 2.6.32
			echo kernel-2.6.32+
		elif [[ $(kver) -ge 33951744 ]] ; then # 2.6.16
			echo kernel-2.6.16+
		elif [[ $(kver) -ge 33947648 ]] ; then # 2.6
			echo kernel-2.6+
		fi
	}

	local FS_INSENSITIVE=0
	touch "${ROOT}"/FOO.$$
	[[ -e ${ROOT}/foo.$$ ]] && FS_INSENSITIVE=1
	rm "${ROOT}"/FOO.$$

	[[ ! -e "${MAKE_CONF_DIR}" ]] && mkdir -p -- "${MAKE_CONF_DIR}"
	if [[ ! -f ${MAKE_CONF_DIR}/0100_bootstrap_prefix_make.conf ]] ; then
		{
			echo "# Added by bootstrap-prefix.sh for ${CHOST}"
			echo 'USE="unicode nls"'
			echo 'CFLAGS="${CFLAGS} -O2 -pipe"'
			echo 'CXXFLAGS="${CFLAGS}"'
			echo "MAKEOPTS=\"${MAKEOPTS}\""
			echo "CONFIG_SHELL=\"${ROOT}/bin/bash\""
			echo "DISTDIR=\"${DISTDIR:-${ROOT}/var/cache/distfiles}\""
			if is-rap ; then
				echo "# sandbox does not work well on Prefix, bug #490246"
				echo 'FEATURES="${FEATURES} -usersandbox -sandbox"'
				# bug #759424
				[[ -n ${STABLE_PREFIX} ]] && \
					echo 'ACCEPT_KEYWORDS="${ARCH} -~${ARCH}"'
			else
				echo "# last mirror is for Prefix specific distfiles, you"
				echo "# might experience fetch failures if you remove it"
				echo "GENTOO_MIRRORS=\"${GENTOO_MIRRORS} ${DISTFILES_PFX}\""
			fi
			if [[ ${FS_INSENSITIVE} == 1 ]] ; then
				echo
				echo "# Avoid problems due to case-insensitivity, bug #524236"
				echo 'FEATURES="${FEATURES} case-insensitive-fs"'
			fi
			[[ -n ${PORTDIR_OVERLAY} ]] && \
				echo "PORTDIR_OVERLAY=\"\${PORTDIR_OVERLAY} ${PORTDIR_OVERLAY}\""
			[[ -n ${MAKE_CONF_ADDITIONAL_USE} ]] &&
				echo "USE=\"\${USE} ${MAKE_CONF_ADDITIONAL_USE}\""
			[[ ${OFFLINE_MODE} ]] && \
				echo 'FETCHCOMMAND="bash -c \"echo I need \${FILE} from \${URI} in \${DISTDIR}; read\""'
		} > "${MAKE_CONF_DIR}/0100_bootstrap_prefix_make.conf"
	fi

	if is-rap ; then
		if [[ ! -f ${ROOT}/etc/passwd ]]; then
			if grep -q $(id -un) /etc/passwd; then
				ln -sf {,"${ROOT}"}/etc/passwd
			else
				getent passwd > "${ROOT}"/etc/passwd
				# add user if it's not in /etc/passwd, bug #766417
				getent passwd $(id -un) >> "${ROOT}"/etc/passwd
			fi
		fi
		if [[ ! -f ${ROOT}/etc/group ]]; then
			if grep -q $(id -gn) /etc/group; then
				ln -sf {,"${ROOT}"}/etc/group
			else
				getent group > "${ROOT}"/etc/group
				# add group if it's not in /etc/group, bug #766417
				getent group $(id -gn) >> "${ROOT}"/etc/group
			fi
		fi
		[[ -f ${ROOT}/etc/resolv.conf ]] || ln -s {,"${ROOT}"}/etc/resolv.conf
		[[ -f ${ROOT}/etc/hosts ]] || cp {,"${ROOT}"}/etc/hosts
		local profile_linux=default/linux/ARCH/17.0/prefix/$(profile-kernel)
	else
		local profile_linux=prefix/linux/ARCH
	fi

	case ${CHOST} in
		powerpc-apple-darwin9)
			rev=${CHOST##*darwin}
			profile="prefix/darwin/macos/10.$((rev - 4))/ppc"
			;;
		i*86-apple-darwin1[578])
			rev=${CHOST##*darwin}
			profile="prefix/darwin/macos/10.$((rev - 4))/x86"
			;;
		x86_64-apple-darwin1[5789])
			rev=${CHOST##*darwin}
			profile="prefix/darwin/macos/10.$((rev - 4))/x64"
			;;
		x86_64-apple-darwin20)
			# Big Sur is 11.0
			rev=${CHOST##*darwin}
			profile="prefix/darwin/macos/11.$((rev - 20))/x64"
			;;
		x86_64-apple-darwin2[123456789])
			# Monterey is 12.0
			rev=${CHOST##*darwin}
			profile="prefix/darwin/macos/12.$((rev - 21))/x64"
			;;
		arm64-apple-darwin20)
			rev=${CHOST##*darwin}
			profile="prefix/darwin/macos/11.$((rev - 20))/arm64"
			;;
		# TODO: Come up with something better for macOS 11+
		x86_64-apple-darwin2[123456789])
			# Monterey is 12.0
			rev=${CHOST##*darwin}
			profile="prefix/darwin/macos/12.$((rev - 21))/x64"
			;;
		arm64-apple-darwin2[123456789])
			# Monterey is 12.0
			rev=${CHOST##*darwin}
			profile="prefix/darwin/macos/12.$((rev - 21))/arm64"
			;;
		i*86-pc-linux-gnu)
			profile=${profile_linux/ARCH/x86}
			;;
		riscv64-pc-linux-gnu)
			profile=${profile_linux/ARCH/riscv}
			profile=${profile/17.0/20.0/rv64gc/lp64d}
			;;
		x86_64-pc-linux-gnu)
			profile=${profile_linux/ARCH/amd64}
			profile=${profile/17.0/17.1/no-multilib}
			;;
		powerpc-unknown-linux-gnu)
			profile=${profile_linux/ARCH/ppc}
			;;
		powerpc64-unknown-linux-gnu)
			profile=${profile_linux/ARCH/ppc64}
			;;
		powerpc64le-unknown-linux-gnu)
			profile=${profile_linux/ARCH/ppc64le}
			;;
		riscv-pc-unknown-linux-gnu)
			profile=${profile_linux/ARCH/riscv}
			profile=${profile/17.0/20.0/rv64gc/lp64d}
			;;
		aarch64-unknown-linux-gnu)
			profile=${profile_linux/ARCH/arm64}
			;;
		armv7l-pc-linux-gnu)
			profile=${profile_linux/ARCH/arm}
			;;
		i386-pc-solaris2.11)
			profile="prefix/sunos/solaris/5.11/x86"
			;;
		x86_64-pc-solaris2.11)
			profile="prefix/sunos/solaris/5.11/x64"
			;;
		sparc-sun-solaris2.11)
			profile="prefix/sunos/solaris/5.11/sparc"
			;;
		sparcv9-sun-solaris2.11)
			profile="prefix/sunos/solaris/5.11/sparc64"
			;;
		i586-pc-winnt*)
			profile="prefix/windows/winnt/${CHOST#i586-pc-winnt}/x86"
			;;
		x86_64-pc-cygwin*)
			profile="prefix/windows/cygwin/x64"
			;;
		*)
			eerror "UNKNOWN ARCH: You need to set up a make.profile symlink to a"
			eerror "profile in ${PORTDIR} for your CHOST ${CHOST}"
			exit 1
			;;
	esac

	if [[ ${CHOST} == *-darwin* ]] ; then
		# setup MacOSX.sdk symlink for GCC, this should probably be
		# managed using an eselect module in the future
		rm -f "${ROOT}"/MacOSX.sdk
		local SDKPATH=$(xcrun --show-sdk-path --sdk macosx)
		if [[ ! -e ${SDKPATH} ]] ; then
			SDKPATH=$(xcodebuild -showsdks | sort -nr \
				| grep -o "macosx.*" | head -n1)
			SDKPATH=$(xcode-select -print-path)/SDKs/MacOSX${SDKPATH#macosx}.sdk
		fi
		( cd "${ROOT}" && ln -s "${SDKPATH}" MacOSX.sdk )
		einfo "using system sources from ${SDKPATH}"
	fi

	if [[ ${DARWIN_USE_GCC} == 1 ]] ; then
		# amend profile, to use gcc one
		profile="${profile}/gcc"
	fi

	[[ -n ${PROFILE_BASE}${PROFILE_VARIANT} ]] &&
	profile=${PROFILE_BASE:-prefix}/${profile#prefix/}${PROFILE_VARIANT:+/${PROFILE_VARIANT}}
	if [[ -n ${profile} && ! -e ${ROOT}/etc/portage/make.profile ]] ; then
		local fullprofile="${PORTDIR}/profiles/${profile}"

		ln -s "${fullprofile}" "${ROOT}"/etc/portage/make.profile
		einfo "Your profile is set to ${fullprofile}."
	fi

	is-rap && cat >> "${ROOT}"/etc/portage/make.profile/make.defaults <<-'EOF'
	# For baselayout-prefix in stage2 only.
	ACCEPT_KEYWORDS="~${ARCH}-linux"
	EOF

	# bug #788613 avoid gcc-11 during stage 2/3 prior sync/emerge -e
	is-rap && cat >> "${ROOT}"/etc/portage/make.profile/package.mask <<-EOF
	# during bootstrap mask, bug #788613
	>=sys-devel/gcc-11
	EOF

	# bug #824482 avoid glibc-2.34
	if is-rap; then
		if ! [ -d "${ROOT}"/etc/portage/package.mask ]; then
			mkdir "${ROOT}"/etc/portage/package.mask
		fi

		if ! [ -d "${ROOT}"/etc/portage/package.unmask ]; then
			mkdir "${ROOT}"/etc/portage/package.unmask
		fi

		cat >> "${ROOT}"/etc/portage/package.mask/glibc <<-EOF
		# Temporary mask for newer glibc until bootstrapping issues are fixed.
		# bug #824482: Avoid glibc-2.34 for now. See package.unmask/glibc too.
		>=sys-libs/glibc-2.34
		EOF

		cat >> "${ROOT}"/etc/portage/package.unmask/glibc <<-EOF
		# Temporary mask for newer glibc until bootstrapping issues are fixed.
		# bug #824482: Avoid glibc-2.34 for now. See package.mask/glibc too.
		>=sys-libs/glibc-2.34_p1
		EOF
	fi

	# Use package.use to disable in the portage tree to be shared between
	# stage2 and stage3. The hack will be undone during tree sync in stage3.
	cat >> "${ROOT}"/etc/portage/make.profile/package.use <<-EOF
	# Disable bootstrapping libcxx* with libunwind
	sys-libs/libcxxabi -libunwind
	sys-libs/libcxx -libunwind
	# Most binary Linux distributions seem to fancy toolchains that
	# do not do c++ support (need to install a separate package).
	sys-libs/ncurses -cxx
	sys-devel/binutils -cxx
	EOF

	# On Darwin we might need this to bootstrap the compiler, since
	# bootstrapping the linker (binutils-apple) requires a c++11
	# compiler amongst other things
	cat >> "${ROOT}"/etc/portage/make.profile/package.unmask <<-EOF
	# For Darwin bootstraps
	sys-devel/native-cctools
	EOF

	[[ ${CHOST} == arm64-*-darwin* ]] &&
	cat >> "${ROOT}"/etc/portage/package.accept_keywords <<-EOF
	=sys-devel/gcc-11_pre20200206 **
	EOF

	# Strange enough, -cxx causes wrong libtool config on Cygwin,
	# but we require a C++ compiler there anyway - so just use it.
	[[ ${CHOST} == *-cygwin* ]] ||
		cat >> "${ROOT}"/etc/portage/make.profile/package.use <<-EOF
	# gmp has cxx flag enabled by default. When dealing with a host
	# compiler without cxx support this causes configure failure.
	# In addition, The stage2 g++ is only for compiling stage3 compiler,
	# because the host libstdc++.so runtime may be not compatible and
	# stage2 libstdc++.so might conflict with that of stage3.  The
	# trade-off is just not to use cxx.
	dev-libs/gmp -cxx
	sys-devel/binutils -gold
	EOF
}

do_tree() {
	local x
	for x in etc{,/portage} usr/{{,s}bin,$(rapx "" lib)} var/tmp var/lib/portage var/log/portage var/db;
	do
		[[ -d ${ROOT}/${x} ]] || mkdir -p "${ROOT}/${x}"
	done
	# Make symlinks as USE=split-usr is masked in prefix/rpath. This is
	# necessary for Cygwin, as there is no such thing like an
	# embedded runpath. Instead we put all the dlls next to the
	# exes, to get them working even without the PATH environment
	# variable being set up.
	#
	# In prefix/standalone, however, no symlink is desired.
	# Because we keep USE=split-usr enabled to align with the
	# default of Gentoo vanilla.
	if ! is-rap; then
		for x in lib sbin bin; do
			[[ -e ${ROOT}/${x} ]] || ( cd "${ROOT}" && ln -s usr/${x} )
		done
	fi

	mkdir -p "${PORTDIR}"
	if [[ ! -e ${PORTDIR}/.unpacked ]]; then
		# latest tree cannot be fetched from mirrors, always have to
		# respect the source to get the latest
		if [[ -n ${LATEST_TREE_YES} ]] ; then
			echo "$1"
			( export GENTOO_MIRRORS= DISTFILES_G_O= DISTFILES_PFX= ;
			  efetch "$1/$2" ) || return 1
		else
			efetch "$1/$2" || return 1
		fi
		einfo "Unpacking, this may take a while"
		estatus "stage1: unpacking Portage tree"
		bzip2 -dc ${DISTDIR}/$2 | tar -xf - -C ${PORTDIR} --strip-components=1
		[[ ${PIPESTATUS[*]} == '0 0' ]] || return 1
		touch ${PORTDIR}/.unpacked
	fi
}

bootstrap_tree() {
	# RAP uses the latest gentoo main repo snapshot to bootstrap.
	is-rap && LATEST_TREE_YES=1
	local PV="20220629"
	if [[ -n ${LATEST_TREE_YES} ]]; then
		do_tree "${SNAPSHOT_URL}" portage-latest.tar.bz2
	else
		do_tree http://dev.gentoo.org/~grobian/distfiles prefix-overlay-${PV}.tar.bz2
	fi
	local ret=$?
	if [[ -n ${TREE_FROM_SRC} ]]; then
		estatus "stage1: rsyncing Portage tree"
		rsync -av --delete \
			--exclude=.unpacked \
			--exclude=distfiles \
			--exclude=snapshots \
			"${TREE_FROM_SRC}"/ "${PORTDIR}"/
	fi
	return $ret
}

bootstrap_startscript() {
	local theshell=${SHELL##*/}
	if [[ ${theshell} == "sh" ]] ; then
		einfo "sh is a generic shell, using bash instead"
		theshell="bash"
	fi
	if [[ ${theshell} == "csh" ]] ; then
		einfo "csh is a prehistoric shell not available in Gentoo, switching to tcsh instead"
		theshell="tcsh"
	fi
	einfo "Trying to emerge the shell you use, if necessary by running:"
	einfo "emerge -u ${theshell}"
	if ! emerge -u ${theshell} ; then
		eerror "Your shell is not available in portage, hence we cannot" > /dev/stderr
		eerror "automate starting your prefix, set SHELL and rerun this script" > /dev/stderr
		return 1
	fi
	einfo "Finally, emerging prefix-toolkit for your convenience"
	emerge -u app-portage/prefix-toolkit || return 1
	einfo "To start Gentoo Prefix, run the script ${ROOT}/startprefix"

	# see if PATH is kept/respected
	local minPATH="preamble:${BASH%/*}:postlude"
	local theirPATH="$(echo 'echo "${PATH}"' | env LS_COLORS= PATH="${minPATH}" $SHELL -l 2>/dev/null | grep "preamble:.*:postlude")"
	if [[ ${theirPATH} != *"preamble:"*":postlude"* ]] ; then
		einfo "WARNING: your shell initialisation (.cshrc, .bashrc, .profile)"
		einfo "         seems to overwrite your PATH, this effectively kills"
		einfo "         your Prefix.  Change this to only append to your PATH"
	elif [[ ${theirPATH} != "preamble:"* ]] ; then
		einfo "WARNING: your shell initialisation (.cshrc, .bashrc, .profile)"
		einfo "         seems to prepend to your PATH, this might kill your"
		einfo "         Prefix:"
		einfo "         ${theirPATH%%preamble:*}"
		einfo "         You better fix this, YOU HAVE BEEN WARNED!"
	fi
}

prepare_portage() {
	# see bootstrap_portage for explanations.
	mkdir -p "${ROOT}"/bin/. "${ROOT}"/var/log
	[[ -x ${ROOT}/bin/bash ]] || ln -s "${ROOT}"{/tmp,}/bin/bash || return 1
	[[ -x ${ROOT}/bin/sh ]] || ln -s bash "${ROOT}"/bin/sh || return 1
}

bootstrap_portage() {
	# Set TESTING_PV in env if you want to test a new portage before bumping the
	# STABLE_PV that is known to work. Intended for power users only.
	## It is critical that STABLE_PV is the lastest (non-masked) version that is
	## included in the snapshot for bootstrap_tree.
	STABLE_PV="3.0.30.1"
	[[ ${TESTING_PV} == latest ]] && TESTING_PV="3.0.30.1"
	PV="${TESTING_PV:-${STABLE_PV}}"
	A=prefix-portage-${PV}.tar.bz2
	einfo "Bootstrapping ${A%.tar.*}"

	efetch ${DISTFILES_URL}/${A} || return 1

	einfo "Unpacking ${A%.tar.*}"
	export S="${PORTAGE_TMPDIR}"/portage-${PV}
	ptmp=${S}
	rm -rf "${S}" >& /dev/null
	mkdir -p "${S}" >& /dev/null
	cd "${S}"
	bzip2 -dc "${DISTDIR}/${A}" | tar -xf -
	[[ ${PIPESTATUS[*]} == '0 0' ]] || return 1
	S="${S}/prefix-portage-${PV}"
	cd "${S}"

	fix_config_sub

	# disable ipc
	sed -e "s:_enable_ipc_daemon = True:_enable_ipc_daemon = False:" \
		-i lib/_emerge/AbstractEbuildProcess.py || \
		return 1

	# host-provided wget may lack certificates, stage1 wget is without ssl
	[[ $(wget -h) == *"--no-check-certificate"* ]] &&
	sed -e '/wget/s/ --passive-ftp /&--no-check-certificate /' -i cnf/make.globals

	# Portage checks for valid shebangs. These may (xz-utils) originate
	# in CONFIG_SHELL (AIX), which originates in PORTAGE_BASH then.
	# So we need to ensure portage's bash is valid as shebang too.
	# Solaris mkdir chokes on existing symlink-to-dir, trailing /. helps.
	mkdir -p "${ROOT}"/tmp/bin/. || return 1
	[[ -x ${ROOT}/tmp/bin/bash ]] || [[ ! -x ${ROOT}/tmp/usr/bin/bash ]] || ln -s ../usr/bin/bash "${ROOT}"/tmp/bin/bash || return 1
	[[ -x ${ROOT}/tmp/bin/bash ]] || ln -s "${BASH}" "${ROOT}"/tmp/bin/bash || return 1
	[[ -x ${ROOT}/tmp/bin/sh ]] || ln -s bash "${ROOT}"/tmp/bin/sh || return 1
	export PORTAGE_BASH="${ROOT}"/tmp/bin/bash

	einfo "Compiling ${A%.tar.*}"
	econf \
		--with-offset-prefix="${ROOT}"/tmp \
		--with-portage-user="`id -un`" \
		--with-portage-group="`id -gn`" \
		--with-extra-path="${PATH}" \
		|| return 1
	emake || return 1

	einfo "Installing ${A%.tar.*}"
	emake install || return 1

	cd "${ROOT}"
	rm -Rf ${ptmp} >& /dev/null

	# Some people will skip the tree() step and hence var/log is not created
	# As such, portage complains..
	mkdir -p "${ROOT}"/tmp/var/log

	# in Prefix the sed wrapper is deadly, so kill it
	rm -f "${ROOT}"/tmp/usr/lib/portage/bin/ebuild-helpers/sed

	local tmpportdir=${ROOT}/tmp/${PORTDIR#${ROOT}}
	[[ -e "${tmpportdir}" ]] || ln -s "${PORTDIR}" "${tmpportdir}"
	for d in "${ROOT}"/tmp/usr/lib/python?.?; do
		[[ -e ${d}/portage ]] || ln -s "${ROOT}"/tmp/usr/lib/portage/lib/portage ${d}/portage
		[[ -e ${d}/_emerge ]] || ln -s "${ROOT}"/tmp/usr/lib/portage/lib/_emerge ${d}/_emerge
	done

	if [[ -s ${PORTDIR}/profiles/repo_name ]]; then
		# sync portage's repos.conf with the tree being used
		sed -i -e "s,gentoo_prefix,$(<"${PORTDIR}"/profiles/repo_name)," "${ROOT}"/tmp/usr/share/portage/config/repos.conf || return 1
	fi

	einfo "${A%.tar.*} successfully bootstrapped"
}

fix_config_sub() {
	# macOS Big Sur (11.x, darwin20) supports Apple Silicon (arm64),
	# which config.sub doesn't understand about.  It is, however, Apple
	# who seem to use arm64-apple-darwin20 CHOST triplets, so patch that
	# for various versions of autoconf
	if [[ ${CHOST} == arm64-apple-darwin* ]] ; then
		# Apple Silicon doesn't use aarch64, but arm64
		find . -name "config.sub" | \
			xargs sed -i -e 's/ arm\(-\*\)* / arm\1 | arm64\1 /'
		find . -name "config.sub" | \
			xargs sed -i -e 's/ aarch64 / aarch64 | arm64 /'
	fi
}

bootstrap_simple() {
	local PN PV A S myconf
	PN=$1
	PV=$2
	A=${PN}-${PV}.tar.${3:-gz}
	einfo "Bootstrapping ${A%.tar.*}"

	efetch ${4:-${DISTFILES_G_O}/distfiles}/${A} || return 1

	einfo "Unpacking ${A%.tar.*}"
	S="${PORTAGE_TMPDIR}/${PN}-${PV}"
	rm -rf "${S}"
	mkdir -p "${S}"
	cd "${S}"
	case $3 in
		xz)    decomp=xz    ;;
		bz2)   decomp=bzip2 ;;
		gz|"") decomp=gzip  ;;
	esac
	${decomp} -dc "${DISTDIR}"/${A} | tar -xf -
	[[ ${PIPESTATUS[*]} == '0 0' ]] || return 1
	S="${S}"/${PN}-${PV}
	cd "${S}"

	fix_config_sub

	# for libressl, only provide static lib, such that wget (above)
	# links it in and we don't have to bother about RPATH or something
	if [[ ${PN} == "libressl" ]] ; then
		myconf="${myconf} --enable-static --disable-shared"
	fi

	einfo "Compiling ${A%.tar.*}"
	if [[ -x configure ]] ; then
		econf ${myconf} || return 1
	fi
	emake || return 1

	einfo "Installing ${A%.tar.*}"
	emake PREFIX="${ROOT}"/tmp/usr install || return 1

	cd "${ROOT}"
	rm -Rf "${S}"
	einfo "${A%.tar.*} successfully bootstrapped"
}

bootstrap_gnu() {
	local PN PV A S
	PN=$1
	PV=$2

	einfo "Bootstrapping ${A%.tar.*}"

	for t in tar.xz tar.bz2 tar.gz tar ; do
		A=${PN}-${PV}.${t}

		# save the user some useless downloading
		if [[ ${t} == tar.gz ]] ; then
			type -P gzip > /dev/null || continue
		fi
		if [[ ${t} == tar.xz ]] ; then
			type -P xz > /dev/null || continue
		fi
		if [[ ${t} == tar.bz2 ]] ; then
			type -P bzip2 > /dev/null || continue
		fi

		URL=${GNU_URL}/${PN}/${A}
		efetch ${URL} || continue

		einfo "Unpacking ${A%.tar.*}"
		S="${PORTAGE_TMPDIR}/${PN}-${PV}"
		rm -rf "${S}"
		mkdir -p "${S}"
		cd "${S}"
		case ${t} in
			tar.xz)  decomp=xz    ;;
			tar.bz2) decomp=bzip2 ;;
			tar.gz)  decomp=gzip  ;;
			tar)
				tar -xf "${DISTDIR}"/${A} || continue
				break
				;;
			*)
				einfo "unhandled extension: $t"
				return 1
				;;
		esac
		${decomp} -dc "${DISTDIR}"/${URL##*/} | tar -xf -
		[[ ${PIPESTATUS[*]} == '0 0' ]] || continue
		break
	done
	S="${S}"/${PN}-${PV}
	[[ -d ${S} ]] || return 1
	cd "${S}" || return 1

	# Tar upstream bug #59755 for broken build on macOS:
	# https://savannah.gnu.org/bugs/index.php?59755
	if [[ ${PN}-${PV} == "tar-1.32" ]] ; then
		local tar_patch_file="tar-1.32-check-sys-ioctl-header-configure.patch"
		local tar_patch_id="file_id=50554"
		local tar_patch_url="https://file.savannah.gnu.org/file/${tar_patch_file}?${tar_patch_id}"
		efetch "${tar_patch_url}" || return 1
		# If fetched from upstream url instead of mirror, filename will
		# have a suffix. Remove suffix by copy, not move, to not
		# trigger refetch on repeated invocations of this script.
		if [[ -f "${DISTDIR}/${tar_patch_file}?${tar_patch_id}" ]]; then
			cp ${DISTDIR}/${tar_patch_file}{?${tar_patch_id},} || return 1
		fi
		patch -p1 < ${DISTDIR}/${tar_patch_file} || return 1
	fi

	if [[ ${PN}-${PV} == "bash-4.3" && ${CHOST} == *-cygwin* ]] ; then
		local p patchopts
		for p in \
			"-p0" \
			"${DISTFILES_G_O}/distfiles/bash43-"{001..048} \
			"-p2" \
			"https://dev.gentoo.org/~haubi/distfiles/bash-4.3_p39-cygwin-r2.patch" \
		; do
			if [[ ${p} == -* ]] ; then
				patchopts=${p}
				continue
			fi
			efetch "${p}" || return 1
			patch --forward --no-backup-if-mismatch ${patchopts} \
				< "${DISTDIR}/${p##*/}" || return 1
		done
	fi

	local myconf=""
	if [[ ${PN} == "make" && ${PV} == "4.2.1" ]] ; then
		if [[ ${CHOST} == *-linux-gnu* ]] ; then
			# force this, macros aren't set correctly with newer glibc
			export CPPFLAGS="${CPPFLAGS} -D__alloca=alloca -D__stat=stat"
		fi
	fi

	if [[ ${PN} == "m4" ]] ; then
		# drop _GL_WARN_ON_USE which gets turned into an error with
		# recent GCC 1.4.17 and below only, on 1.4.18 this expression
		# doesn't match
		sed -i -e '/_GL_WARN_ON_USE (gets/d' lib/stdio.in.h lib/stdio.h

		if [[ ${PV} == "1.4.18" ]] ; then
			# macOS 10.13 have an issue with %n, which crashes m4
			efetch "http://rsync.prefix.bitzolder.nl/sys-devel/m4/files/m4-1.4.18-darwin17-printf-n.patch" || return 1
			patch -p1 < "${DISTDIR}"/m4-1.4.18-darwin17-printf-n.patch || return 1

			# Bug 715880
			efetch http://dev.gentoo.org/~heroxbd/m4-1.4.18-glibc228.patch || return 1
			patch -p1 < "${DISTDIR}"/m4-1.4.18-glibc228.patch || return 1
		fi
	fi

	fix_config_sub

	if [[ ${PN} == "grep" ]] ; then
		# Solaris and OSX don't like it when --disable-nls is set,
		# so just don't set it at all.
		# Solaris 11 has a messed up prce installation.  We don't need
		# it anyway, so just disable it
		myconf="${myconf} --disable-perl-regexp"
	fi

	# pod2man may be too old (not understanding --utf8) but we don't
	# care about manpages at this stage
	export ac_cv_path_POD2MAN=no

	# Darwin9 in particular doesn't compile when using system readline,
	# but we don't need any groovy input handling at all, so just disable it
	[[ ${PN} == "bash" ]] && myconf="${myconf} --disable-readline"

	# On e.g. musl systems bash will crash with a malloc error if we use
	# bash' internal malloc, so disable it during it this stage
	[[ ${PN} == "bash" ]] && \
		myconf="${myconf} --without-bash-malloc"

	# Ensure we don't read system-wide shell initialisation, it may
	# contain cruft, bug #650284
	[[ ${PN} == "bash" ]] && \
		export CPPFLAGS="${CPPFLAGS} \
			-DSYS_BASHRC=\\\"${ROOT}/etc/bash/bashrc\\\" \
			-DSYS_BASH_LOGOUT=\\\"${ROOT}/etc/bash/bash_logout\\\" \
		"

	# Don't do ACL stuff on Darwin, especially Darwin9 will make
	# coreutils completely useless (install failing on everything)
	# Don't try using gmp either, it may be that just the library is
	# there, and if so, the buildsystem assumes the header exists too
	# stdbuf is giving many problems, and we don't really care about it
	# at this level, so disable it too
	if [[ ${PN} == "coreutils" ]] ; then
		myconf="${myconf} --disable-acl --without-gmp"
		myconf="${myconf} --enable-no-install-program=stdbuf"
	fi

	# Gentoo Bug 400831, fails on Ubuntu with libssl-dev installed
	if [[ ${PN} == "wget" ]] ; then
		if [[ -x ${ROOT}/tmp/usr/bin/openssl ]] ; then
			myconf="${myconf} --with-ssl=openssl"
			myconf="${myconf} --with-libssl-prefix=${ROOT}/tmp/usr"
			export CPPFLAGS="${CPPFLAGS} -I${ROOT}/tmp/usr/include"
			export LDFLAGS="${LDFLAGS} -L${ROOT}/tmp/usr/lib"
		else
			myconf="${myconf} --without-ssl"
		fi
	fi

	# SuSE 11.1 has GNU binutils-2.20, choking on crc32_x86
	[[ ${PN} == "xz" ]] && myconf="${myconf} --disable-assembler"

	if [[ ${PN} == "libffi" ]] ; then
		# we do not have pkg-config to find lib/libffi-*/include/ffi.h
		sed -i -e '/includesdir =/s/=.*/= $(includedir)/' include/Makefile.in
		# force install into libdir
		myconf="${myconf} --libdir=${ROOT}/tmp/usr/lib"
		sed -i -e '/toolexeclibdir =/s/=.*/= $(libdir)/' Makefile.in
		# we have to build the libraries for correct bitwidth
		case $CHOST in
		(x86_64-*-*|sparcv9-*-*)
			export CFLAGS="-m64"
			;;
		(i?86-*-*)
			export CFLAGS="-m32"
			;;
		(arm64-*-darwin*)
			sed -i -e 's/aarch64\*-\*-\*/arm64*-*-*|&/' \
				configure configure.host
			;;
		esac
	fi

	einfo "Compiling ${A%.tar.*}"
	econf ${myconf} || return 1
	if [[ ${PN} == "make" && $(type -t $MAKE) != "file" ]]; then
		estatus "stage1: building ${A%.tar.*}"
		v ./build.sh || return 1
	else
		emake || return 1
	fi

	einfo "Installing ${A%.tar.*}"
	if [[ ${PN} == "make" && $(type -t $MAKE) != "file" ]]; then
		estatus "stage1: installing ${A%.tar.*}"
		v ./make install MAKE="${S}/make" || return 1
	else
		emake install || return 1
	fi

	cd "${ROOT}"
	rm -Rf "${S}"
	einfo "${A%.tar.*} successfully bootstrapped"
}

PYTHONMAJMIN=3.9   # keep this number in line with PV below for stage1,2
bootstrap_python() {
	PV=3.9.13
	A=Python-${PV}.tar.xz
	einfo "Bootstrapping ${A%.tar.*}"

	efetch https://www.python.org/ftp/python/${PV}/${A}

	einfo "Unpacking ${A%.tar.*}"
	export S="${PORTAGE_TMPDIR}/python-${PV}"
	rm -rf "${S}"
	mkdir -p "${S}"
	cd "${S}"
	case ${A} in
		*bz2) bzip2 -dc "${DISTDIR}"/${A} | tar -xf - ;;
		*xz)  xz -dc "${DISTDIR}"/${A} | tar -xf -    ;;
		*)    einfo "Don't know to unpack ${A}"       ;;
	esac
	[[ ${PIPESTATUS[*]} == '0 0' ]] || return 1
	S="${S}"/Python-${PV}
	cd "${S}"
	rm -rf Modules/_ctypes/libffi* || return 1
	rm -rf Modules/zlib || return 1

	case ${CHOST} in
	(*-*-cygwin*)
		local gitrev cygpyver pf pn patch_folder ffail

		# try github first, if that fails, it means that cygwin has not
		# archived that repo yet
		# ideally the version of python used by bootstrap would be one
		# that cygwin has packaged if we don't do exact matches on the
		# version then some patches may not apply cleanly

		ffail=0
		gitrev="42494e325a050ba03638568d7318f8f0075e25fb"
		efetch "https://github.com/cygwinports/python39/archive/${gitrev}.tar.gz" \
			|| ffail=1
		if [[ -z ${ffail} ]]; then
			gzip -dc "${DISTDIR}"/"${gitrev}.tar.gz" | tar -xf -
			[[ ${PIPESTATUS[*]} == '0 0' ]] || return 1
			patch_folder="python39-${gitrev}"
		else
			cygpyver="3.9.9-1"
			efetch "https://mirrors.kernel.org/sourceware/cygwin/x86_64/release/python39/python39-${cygpyver}-src.tar.xz" \
				|| return 1
			xz -dc "${DISTDIR}"/"python39-${cygpyver}-src.tar.xz" | tar -xf -
			[[ ${PIPESTATUS[*]} == '0 0' ]] || return 1
			patch_folder="python39-${cygpyver}.src"
			ffail=0
		fi
		[[ ${ffail} == 0 ]] || return 1

		for pf in $(
			sed -ne '/PATCH_URI="/,/"/{s/.*="//;s/".*$//;p}' \
				< "${patch_folder}/python39.cygport" \
				| grep -v rpm-wheels | grep -v revert-bpo
		); do
			pf="${patch_folder}/${pf}"
			for pn in {1..2} fail; do
				if [[ ${pn} == fail ]]; then
					eerror "failed to apply ${pf}"
					return 1
				fi
				patch -N -p${pn} -i "${pf}" --dry-run >/dev/null 2>&1 \
					|| continue
				echo "applying (-p${pn}) ${pf}"
				patch -N -p${pn} -i "${pf}" || return 1
				break
			done
		done
		;;
	(*-solaris*)
		# Solaris' host compiler (if old -- 3.4.3) doesn't grok HUGE_VAL,
		# and barfs on isnan() so patch it out
		sed -i \
			-e '/^#define Py_HUGE_VAL/s/HUGE_VAL$/(__builtin_huge_val())/' \
			-e '/defined HAVE_DECL_ISNAN/s/ISNAN/USE_FALLBACK/' \
			Include/pymath.h
		;;
	(*-darwin9)
		# Darwin 9's kqueue seems to act up (at least at this stage), so
		# make Python's selectors resort to poll() or select() for the
		# time being
		sed -i \
			-e 's/KQUEUE/KQUEUE_DISABLED/' \
			configure
		# fixup thread id detection
		efetch "https://dev.gentoo.org/~sam/distfiles/dev-lang/python/python-3.9.6-darwin9_pthreadid.patch"
		patch -p1 < "${DISTDIR}"/python-3.9.6-darwin9_pthreadid.patch
		;;
	(arm64-*-darwin*)
		# Teach Python a new trick (arm64)
		sed -i \
			-e "/Unexpected output of 'arch' on OSX/d" \
			configure
		;;
	(*-openbsd*)
		# OpenBSD is not a multilib system
		sed -i \
			-e '0,/#if defined(__ANDROID__)/{s/ANDROID/OpenBSD/}' \
			-e '0,/MULTIARCH=/{s/\(MULTIARCH\)=.*/\1=""/}' \
			configure
		;;
	esac

	case ${CHOST} in
	(*-darwin*)
		# avoid triggering compiled out system proxy retrieval code (_scproxy)
		sed -i -e '/sys.platform/s/darwin/disabled-darwin/' \
			Lib/urllib/request.py
		;;
	esac

	fix_config_sub

	local myconf=""

	case ${CHOST} in
	(x86_64-*-*|sparcv9-*-*)
		export CFLAGS="-m64"
		;;
	(i?86-*-*)
		export CFLAGS="-m32"
		;;
	esac

	case ${CHOST} in
		*-*-cygwin*)
			# --disable-shared would link modules against "python.exe"
			# so renaming to "pythonX.Y.exe" will break them.
			# And ctypes dynamically loads "libpythonX.Y.dll" anyway.
			myconf="${myconf} --enable-shared"
		;;
		*-linux*)
			# Bug 382263: make sure Python will know about the libdir in use for
			# the current arch
			libdir="-L/usr/lib/$(gcc ${CFLAGS} -print-multi-os-directory)"
		;;
		x86_64-*-solaris*|sparcv9-*-solaris*)
			# Like above, make Python know where GCC's 64-bits
			# libgcc_s.so is on Solaris
			libdir="-L/usr/sfw/lib/64"
		;;
		*-solaris*) # 32bit
			libdir="-L/usr/sfw/lib"
		;;
	esac

	# python refuses to find the zlib headers that are built in the offset,
	# same for libffi, which installs into compiler's multilib-osdir
	export CPPFLAGS="-I${ROOT}/tmp/usr/include"
	export LDFLAGS="${CFLAGS} -L${ROOT}/tmp/usr/lib"
	# set correct flags for runtime for ELF platforms
	case ${CHOST} in
		*-linux*)
			# GNU ld
			LDFLAGS="${LDFLAGS} -Wl,-rpath,${ROOT}/tmp/usr/lib ${libdir}"
			LDFLAGS="${LDFLAGS} -Wl,-rpath,${libdir#-L}"
		;;
		*-openbsd*)
			# LLD
			LDFLAGS="${LDFLAGS} -Wl,-rpath,${ROOT}/tmp/usr/lib"
		;;
		*-solaris*)
			# Sun ld
			LDFLAGS="${LDFLAGS} -R${ROOT}/tmp/usr/lib ${libdir}"
			LDFLAGS="${LDFLAGS} -R${libdir#-L}"
		;;
	esac

	# if the user has a $HOME/.pydistutils.cfg file, the python
	# installation is going to be screwed up, as reported by users, so
	# just make sure Python won't find it
	export HOME="${S}"

	export OPT="${CFLAGS}"

	einfo "Compiling ${A%.tar.*}"

	# - Some ancient versions of hg fail with "hg id -i", so help
	#   configure to not find them using HAS_HG (TODO: obsolete?)
	# - Do not find libffi via pkg-config using PKG_CONFIG
	HAS_HG=no \
	PKG_CONFIG= \
	econf \
		--with-system-ffi \
		--without-ensurepip \
		--disable-ipv6 \
		--disable-shared \
		--libdir="${ROOT}"/tmp/usr/lib \
		${myconf} || return 1
	emake || return 1

	einfo "Installing ${A%.tar.*}"
	emake -k install || echo "??? Python failed to install *sigh* continuing anyway"
	cd "${ROOT}"/tmp/usr/bin
	ln -sf python${PV%.*} python
	cd "${ROOT}"/tmp/usr/lib
	# messes up python emerges, and shouldn't be necessary for anything
	# http://forums.gentoo.org/viewtopic-p-6890526.html
	rm -f libpython${PV%.*}.a

	einfo "${A%.tar.*} bootstrapped"
}

bootstrap_cmake_core() {
	PV=${1:-3.16.5}
	A=cmake-${PV}.tar.gz

	einfo "Bootstrapping ${A%.tar.*}"

	efetch https://github.com/Kitware/CMake/releases/download/v${PV}/${A} \
		|| return 1

	einfo "Unpacking ${A%.tar.*}"
	export S="${PORTAGE_TMPDIR}/cmake-${PV}"
	rm -rf "${S}"
	mkdir -p "${S}"
	cd "${S}"
	gzip -dc "${DISTDIR}"/${A} | tar -xf -
	[[ ${PIPESTATUS[*]} == '0 0' ]] || return 1
	S="${S}"/cmake-${PV}
	cd "${S}"

	# don't set a POSIX standard, system headers don't like that, #757426
	sed -i -e 's/^#if !defined(_WIN32) && !defined(__sun)/& \&\& !defined(__APPLE__)/' \
		Source/cmLoadCommandCommand.cxx \
		Source/cmStandardLexer.h \
		Source/cmSystemTools.cxx \
		Source/cmTimestamp.cxx

	einfo "Bootstrapping ${A%.tar.*}"
	estatus "stage1: configuring ${A%.tar.*}"
	./bootstrap --prefix="${ROOT}"/tmp/usr || return 1

	einfo "Compiling ${A%.tar.*}"
	emake || return 1

	einfo "Installing ${A%.tar.*}"
	emake install || return 1

	# we need sysroot crap to build cmake itself, but it makes trouble
	# later on, so kill it in the installed version
	ver=${A%-*} ; ver=${ver%.*}
	sed -i -e '/cmake_gnu_set_sysroot_flag/d' \
		"${ROOT}"/tmp/usr/share/${ver}/Modules/Platform/Apple-GNU-*.cmake || die
	# disable isysroot usage with clang as well
	sed -i -e '/_SYSROOT_FLAG/d' \
		"${ROOT}"/tmp/usr/share/${ver}/Modules/Platform/Apple-Clang.cmake || die

	einfo "${A%.tar.*} bootstrapped"
}

bootstrap_cmake() {
	bootstrap_cmake_core 3.16.5 || bootstrap_cmake_core 3.0.2
}

bootstrap_zlib_core() {
	# Use 1.2.8 by default, current bootstrap guides
	PV="${1:-1.2.8}"
	A=zlib-${PV}.tar.gz

	einfo "Bootstrapping ${A%.tar.*}"

	efetch ${DISTFILES_G_O}/distfiles/${A} || return 1

	einfo "Unpacking ${A%.tar.*}"
	export S="${PORTAGE_TMPDIR}/zlib-${PV}"
	rm -rf "${S}"
	mkdir -p "${S}"
	cd "${S}"
	case ${A} in
		*.tar.gz) decomp=gzip  ;;
		*)        decomp=bzip2 ;;
	esac
	${decomp} -dc "${DISTDIR}"/${A} | tar -xf -
	[[ ${PIPESTATUS[*]} == '0 0' ]] || return 1
	S="${S}"/zlib-${PV}
	cd "${S}"

	if [[ ${CHOST} == x86_64-*-* || ${CHOST} == sparcv9-*-* ]] ; then
		# 64-bits targets need zlib as library (not just to unpack),
		# hence we need to make sure that we really bootstrap this
		# 64-bits (in contrast to the tools which we don't care if they
		# are 32-bits)
		export CC="${CC} -m64"
	elif [[ ${CHOST} == i?86-*-* ]] ; then
		# This is important for bootstraps which are 64-native, but we
		# want 32-bits, such as most Linuxes, and more recent OSX.
		# OS X Lion and up default to a 64-bits userland, so force the
		# compiler to 32-bits code generation if requested here
		export CC="${CC} -m32"
	fi
	local makeopts=( ${MAKEOPTS} )
	# 1.2.5 suffers from a concurrency problem
	[[ ${PV} == 1.2.5 ]] && makeopts=()

	if [[ ${CHOST} == *-cygwin* ]] ; then
		# gzopen_w is for real _WIN32 only
		sed -i -e '/gzopen_w/d' win32/zlib.def
		makeopts=(
			-f win32/Makefile.gcc
			SHARED_MODE=1
			# avoid toolchain finding ./cygz.dll (esp. in parallel build)
			SHAREDLIB=win32/cygz.dll
			IMPLIB=libz.dll.a
			BINARY_PATH="${ROOT}"/tmp/usr/bin
			INCLUDE_PATH="${ROOT}"/tmp/usr/include
			LIBRARY_PATH="${ROOT}"/tmp/usr/lib
			"${makeopts[@]}"
		)
		# stage1 python searches for lib/libz.dll
		ln -sf libz.dll.a "${ROOT}"/tmp/usr/lib/libz.dll
	fi

	einfo "Compiling ${A%.tar.*}"
	CHOST= ${CONFIG_SHELL} ./configure --prefix="${ROOT}"/tmp/usr || return 1
	MAKEOPTS=
	emake "${makeopts[@]}" || return 1

	einfo "Installing ${A%.tar.*}"
	emake "${makeopts[@]}" -j1 install || return 1

	# this lib causes issues when emerging python again on Solaris
	# because the tmp lib path is in the library search path there
	local x
	for x in "${ROOT}"/tmp/usr/lib/libz*.a ; do
		[[ ${x} == *.dll.a ]] && continue # keep Cygwin import lib
		rm -Rf "${x}"
	done

	einfo "${A%.tar.*} bootstrapped"
}

bootstrap_zlib() {
	bootstrap_zlib_core 1.2.11 || \
	bootstrap_zlib_core 1.2.8 || bootstrap_zlib_core 1.2.7 || \
	bootstrap_zlib_core 1.2.6 || bootstrap_zlib_core 1.2.5
}

bootstrap_libffi() {
	bootstrap_gnu libffi 3.3 || \
	bootstrap_gnu libffi 3.2.1
}

bootstrap_sed() {
	bootstrap_gnu sed 4.5 || \
	bootstrap_gnu sed 4.2.2 || bootstrap_gnu sed 4.2.1
}

bootstrap_findutils() {
	bootstrap_gnu findutils 4.7.0 ||
	bootstrap_gnu findutils 4.5.10 ||
	bootstrap_gnu findutils 4.2.33
}

bootstrap_wget() {
	bootstrap_gnu wget 1.20.1 || \
	bootstrap_gnu wget 1.17.1 || bootstrap_gnu wget 1.13.4
}

bootstrap_grep() {
	# don't use 2.13, it contains a bug that bites, bug #425668
	# 2.9 is the last version provided as tar.gz (platforms without xz)
	# 2.7 is necessary for Solaris/OpenIndiana (2.8, 2.9 fail to configure)
	bootstrap_gnu grep 3.3 || \
	bootstrap_gnu grep 2.9 || bootstrap_gnu grep 2.7 || \
	bootstrap_gnu grep 2.14 || bootstrap_gnu grep 2.12
}

bootstrap_coreutils() {
	# 8.16 is the last version released as tar.gz
	# 8.18 is necessary for macOS High Sierra (darwin17) and converted
	#      to tar.gz for this case
	bootstrap_gnu coreutils 8.32 || bootstrap_gnu coreutils 8.30 || \
	bootstrap_gnu coreutils 8.16 || bootstrap_gnu coreutils 8.17
}

bootstrap_tar() {
	bootstrap_gnu tar 1.32 || bootstrap_gnu tar 1.26
}

bootstrap_make() {
	MAKEOPTS= # no GNU make yet
	bootstrap_gnu make 4.2.1 || return 1
	if [[ ${MAKE} == gmake ]] ; then
		# make make available as gmake
		( cd ${ROOT}/tmp/usr/bin && ln -s make gmake )
	fi
}

bootstrap_patch() {
	# 2.5.9 needed for OSX 10.6.x still?
	bootstrap_gnu patch 2.7.5 ||
	bootstrap_gnu patch 2.7.4 ||
	bootstrap_gnu patch 2.7.3 ||
	bootstrap_gnu patch 2.6.1
}

bootstrap_gawk() {
	bootstrap_gnu gawk 5.0.1 || bootstrap_gnu gawk 4.0.1 || \
		bootstrap_gnu gawk 3.1.8
}

bootstrap_binutils() {
	bootstrap_gnu binutils 2.17
}

bootstrap_texinfo() {
	bootstrap_gnu texinfo 4.8
}

bootstrap_bash() {
	bootstrap_gnu bash 5.1 ||
	bootstrap_gnu bash 4.3 ||
	bootstrap_gnu bash 4.2
}

bootstrap_bison() {
	bootstrap_gnu bison 2.6.2 || bootstrap_gnu bison 2.6.1 || \
	bootstrap_gnu bison 2.6 || bootstrap_gnu bison 2.5.1 || \
	bootstrap_gnu bison 2.4
}

bootstrap_m4() {
	bootstrap_gnu m4 1.4.19 || bootstrap_gnu m4 1.4.18 # version is patched, so beware
}

bootstrap_gzip() {
	bootstrap_gnu gzip 1.4
}

bootstrap_xz() {
	GNU_URL=http://tukaani.org/xz bootstrap_gnu xz 5.2.4 || \
	GNU_URL=http://tukaani.org/xz bootstrap_gnu xz 5.2.3
}

bootstrap_bzip2() {
	bootstrap_simple bzip2 1.0.6 gz \
		https://sourceware.org/pub/bzip2
}

bootstrap_libressl() {
	bootstrap_simple libressl 3.4.3 gz \
		https://ftp.openbsd.org/pub/OpenBSD/LibreSSL || \
	bootstrap_simple libressl 3.2.4 gz \
		https://ftp.openbsd.org/pub/OpenBSD/LibreSSL || \
	bootstrap_simple libressl 2.8.3 gz \
		https://ftp.openbsd.org/pub/OpenBSD/LibreSSL
}

bootstrap_stage_host_gentoo() {
	if ! is-rap ; then
		einfo "Shortcut only supports prefix-standalone, but we "
		einfo "are bootstrapping prefix-rpath.  Do nothing."
		return 0
	fi

	if [[ ! -L ${ROOT}/tmp ]] ; then
		if [[ -e ${ROOT}/tmp ]] ; then
			einfo "${ROOT}/tmp exists and is not a symlink to ${HOST_GENTOO_EROOT}"
			einfo "Let's ignore the shortcut and continue."
		else
			ln -s "${HOST_GENTOO_EROOT}" "${ROOT}"/tmp
		fi
	fi

	# checks itself if things need to be done still
	(bootstrap_tree) || return 1

	# setup a profile
	[[ -e ${ROOT}/etc/portage/make.profile && \
		-e ${MAKE_CONF_DIR}/0100_bootstrap_prefix_make.conf ]] \
		|| (bootstrap_setup) || return 1

	prepare_portage
}

bootstrap_stage1() {
	# NOTE: stage1 compiles all tools (no libraries) in the native
	# bits-size of the compiler, which needs not to match what we're
	# bootstrapping for.  This is no problem since they're just tools,
	# for which it really doesn't matter how they run, as long AS they
	# run.  For libraries, this is different, since they are relied upon
	# by packages we emerge later on.
	# Changing this to compile the tools for the bits the bootstrap is
	# for, is a BAD idea, since we're extremely fragile here, so
	# whatever the native toolchain is here, is what in general works
	# best.

	# See comments in do_tree().
	local portroot=${PORTDIR%/*}
	mkdir -p "${ROOT}"/tmp/${portroot#${ROOT}/}
	for x in lib sbin bin; do
		mkdir -p "${ROOT}"/tmp/usr/${x}
		[[ -e ${ROOT}/tmp/${x} ]] || ( cd "${ROOT}"/tmp && ln -s usr/${x} )
	done

	configure_toolchain
	export CC CXX

	# Run all bootstrap_* commands in a subshell since the targets
	# frequently pollute the environment using exports which affect
	# packages following (e.g. zlib builds 64-bits)

	local CP

	# don't rely on $MAKE, if make == gmake packages that call 'make' fail
	[[ -x ${ROOT}/tmp/usr/bin/make ]] \
		|| [[ $(make --version 2>&1) == *GNU" Make "4* ]] \
		|| (bootstrap_make) || return 1
	[[ ${OFFLINE_MODE} ]] || [[ -x ${ROOT}/tmp/usr/bin/openssl ]] \
		|| (bootstrap_libressl) # do not fail if this fails, we'll try without
	[[ ${OFFLINE_MODE} ]] || type -P wget > /dev/null \
		|| (bootstrap_wget) || return 1
	[[ -x ${ROOT}/tmp/usr/bin/sed ]] \
		|| [[ $(sed --version 2>&1) == *GNU* ]] \
		|| (bootstrap_sed) || return 1
	type -P xz > /dev/null || (bootstrap_xz) || return 1
	type -P bzip2 > /dev/null || (bootstrap_bzip2) || return 1
	[[ -x ${ROOT}/tmp/usr/bin/patch ]] \
		|| [[ $(patch --version 2>&1) == *"patch 2."[6-9]*GNU* ]] \
		|| (bootstrap_patch) || return 1
	[[ -x ${ROOT}/tmp/usr/bin/m4 ]] \
		|| [[ $(m4 --version 2>&1) == *GNU*1.4.1?* ]] \
		|| (bootstrap_m4) || return 1
	[[ -x ${ROOT}/tmp/usr/bin/bison ]] \
		|| [[ $(bison --version 2>&1) == *GNU" "Bison") "2.[3-7]* ]] \
		|| [[ $(bison --version 2>&1) == *GNU" "Bison") "[3-9]* ]] \
		|| (bootstrap_bison) || return 1
	if [[ ! -x ${ROOT}/tmp/usr/bin/uniq ]]; then
		# If the system has a uniq, let's use it to test whether
		# coreutils is new enough (and GNU).
		if [[ $(uniq --version 2>&1) == *"(GNU coreutils) "[6789]* ]]; then
			CP="cp"
		else
			(bootstrap_coreutils) || return 1
		fi
	fi

	# But for e.g. BSD, it isn't going to be, so if our test failed,
	# use bootstrapped coreutils.
	[[ -z ${CP} ]] && CP="${ROOT}/tmp/bin/cp"

	[[ -x ${ROOT}/tmp/usr/bin/find ]] \
		|| [[ $(find --version 2>&1) == *GNU* ]] \
		|| (bootstrap_findutils) || return 1
	[[ -x ${ROOT}/tmp/usr/bin/tar ]] \
		|| [[ $(tar --version 2>&1) == *GNU* ]] \
		|| (bootstrap_tar) || return 1
	[[ -x ${ROOT}/tmp/usr/bin/grep ]] \
		|| [[ $(grep --version 2>&1) == *GNU* ]] \
		|| (bootstrap_grep) || return 1
	[[ -x ${ROOT}/tmp/usr/bin/gawk ]] \
		|| [[ $(awk --version < /dev/null 2>&1) == *GNU" Awk "[456789]* ]] \
		|| bootstrap_gawk || return 1
	# always build our own bash, for we don't know what devilish thing
	# we're working with now, bug #650284
	[[ -x ${ROOT}/tmp/usr/bin/bash ]] \
		|| (bootstrap_bash) || return 1

	# Some host tools need to be wrapped to be useful for us.
	# We put them in tmp/usr/local/bin, to not accidentally
	# be identified as stage1-installed like in bug #615410.
	mkdir -p "${ROOT}"/tmp/usr/local/bin
	case ${CHOST} in
		*-darwin*)
			# Recent Mac OS X have a nice popup to install java when
			# it's called without being installed, this doesn't stop the
			# process from going, but keeps popping up a dialog during
			# the bootstrap process, which is slightly anoying.
			# Nevertheless, we don't want Java when it's installed to be
			# detected, so hide during the stage builds
			{
				echo "#!$(type -P false)"
			} > "${ROOT}"/tmp/usr/local/bin/java
			cp "${ROOT}"/tmp/usr/local/bin/java{,c}
			chmod 755 "${ROOT}"/tmp/usr/local/bin/java{,c}
			;;
		*-linux*)
			if [[ ! -x "${ROOT}"/tmp/usr/bin/gcc ]] \
			&& [[ $(gcc -print-prog-name=as),$(gcc -print-prog-name=ld) != /*,/* ]]
			then
				# RHEL's system gcc is set up to use binutils via PATH search.
				# If the version of our binutils an older one, they may not
				# provide what the system gcc is configured to use.
				# We need to direct the system gcc to find the system binutils.
				cat >> "${ROOT}"/tmp/usr/local/bin/gcc <<-EOF
					#! /bin/sh
					PATH="${ORIGINAL_PATH}" export PATH
					exec "$(type -P gcc)" "\$@"
				EOF
				cat >> "${ROOT}"/tmp/usr/local/bin/g++ <<-EOF
					#! /bin/sh
					PATH="${ORIGINAL_PATH}" export PATH
					exec "$(type -P g++)" "\$@"
				EOF
				chmod 755 "${ROOT}"/tmp/usr/local/bin/g{cc,++}
			fi
			;;
	esac
	# Host compiler can output a variety of libdirs.  At stage1,
	# they should be the same as lib.  Otherwise libffi may not be
	# found by python.
	if is-rap ; then
		[[ -d ${ROOT}/tmp/usr/lib ]] || mkdir -p "${ROOT}"/tmp/usr/lib
		local libdir
		for libdir in lib64 lib32 libx32; do
			if [[ ! -L ${ROOT}/tmp/usr/${libdir} ]] ; then
				if [[ -e "${ROOT}"/tmp/usr/${libdir} ]] ; then
					echo "${ROOT}"/tmp/usr/${libdir} should be a symlink to lib
					return 1
				fi
				ln -s lib "${ROOT}"/tmp/usr/${libdir}
			fi
		done
	fi

	# important to have our own (non-flawed one) since Python (from
	# Portage) and binutils use it
	# note that this actually breaks the concept of stage1, this will be
	# compiled for the target prefix
	for zlib in ${ROOT}/tmp/usr/lib/libz.* ; do
		[[ -e ${zlib} ]] && break
		zlib=
	done
	[[ -n ${zlib} ]] || (bootstrap_zlib) || return 1
	for libffi in ${ROOT}/tmp/usr/lib*/libffi.* ; do
		[[ -e ${libffi} ]] && break
		libffi=
	done
	[[ -n ${libffi} ]] || (bootstrap_libffi) || return 1
	# too vital to rely on a host-provided one
	[[ -x ${ROOT}/tmp/usr/bin/python ]] || (bootstrap_python) || return 1

	# cmake for llvm/clang toolchain on macOS
	[[ -e ${ROOT}/tmp/usr/bin/cmake ]] \
		|| [[ ${CHOST} != *-darwin* ]] \
		|| [[ ${DARWIN_USE_GCC} == 1 ]] \
		|| (bootstrap_cmake) || return 1

	# checks itself if things need to be done still
	(bootstrap_tree) || return 1

	# setup a profile
	[[ -e ${ROOT}/etc/portage/make.profile && \
		-e ${MAKE_CONF_DIR}/0100_bootstrap_prefix_make.conf ]] \
		|| (bootstrap_setup) || return 1
	mkdir -p "${ROOT}"/tmp/etc/. || return 1
	[[ -e ${ROOT}/tmp/etc/portage/make.profile ]] || "${CP}" -dpR "${ROOT}"/etc/portage "${ROOT}"/tmp/etc || return 1

	# setup portage
	[[ -e ${ROOT}/tmp/usr/bin/emerge ]] || (bootstrap_portage) || return 1
	prepare_portage

	estatus "stage1 finished"
	einfo "stage1 successfully finished"
}

bootstrap_stage1_log() {
	bootstrap_stage1 ${@} 2>&1 | tee -a ${ROOT}/stage1.log
	local ret=${PIPESTATUS[0]}
	[[ ${ret} == 0 ]] && touch ${ROOT}/.stage1-finished
	return ${ret}
}

do_emerge_pkgs() {
	local opts=$1 ; shift
	local pkg vdb pvdb evdb
	for pkg in "$@"; do
		vdb=${pkg}
		if [[ ${vdb} == "="* ]] ; then
			vdb=${vdb#=}
		elif [[ ${vdb} == "<"* ]] ; then
			vdb=${vdb#<}
			vdb=${vdb%-r*}
			vdb=${vdb%-*}
			vdb=${vdb}-\*
		else
			vdb=${vdb}-\*
		fi
		for pvdb in ${EPREFIX}/var/db/pkg/${vdb%-*}-* ; do
			if [[ -d ${pvdb} ]] ; then
				evdb=${pvdb##*/}
				if [[ ${pkg} == "="* ]] ; then
					# exact match required (* should work here)
					[[ ${evdb} == ${vdb##*/} ]] && break
				else
					vdb=${vdb%-*}
					evdb=${evdb%-r*}
					evdb=${evdb%_p*}
					evdb=${evdb%-*}
					[[ ${evdb} == ${vdb#*/} ]] && break
				fi
			fi
			pvdb=
		done
		[[ -n ${pvdb} ]] && continue

		local myuse=(
			-acl
			-berkdb
			-fortran
			-gdbm
			-git
			-libcxx
			-nls
			-pcre
			-python
			-qmanifest -qtegrity
			-readline
			-sanitize
			bootstrap
			clang
			internal-glib
		)
		local override_make_conf_dir="${PORTAGE_OVERRIDE_EPREFIX}${MAKE_CONF_DIR#${ROOT}}"

		if [[ " ${USE} " == *" prefix-stack "* ]] &&
		   [[ ${PORTAGE_OVERRIDE_EPREFIX} == */tmp ]] &&
		   ! grep -Rq '^USE=".*" # by bootstrap-prefix.sh$' \
		   "${override_make_conf_dir}"
		then
			# With prefix-stack, the USE env var does apply to the stacked
			# prefix only, not the base prefix (any more? since some portage
			# version?), so we have to persist the base USE flags into the
			# base prefix - without the additional incoming USE flags.
			mkdir -p -- "${override_make_conf_dir}"
			echo "USE=\"\${USE} ${myuse[*]}\" # by bootstrap-prefix.sh" \
				>> "${override_make_conf_dir}/0101_bootstrap_prefix_stack.conf"
		fi
		myuse=" ${myuse[*]} "
		local use
		for use in ${USE} ; do
			myuse=" ${myuse/ ${use} /} "
			myuse=" ${myuse/ -${use} /} "
			myuse=" ${myuse/ ${use#-} /} "
			myuse+=" ${use} "
		done
		myuse=( ${myuse} )

		# Disable the STALE warning because the snapshot frequently gets stale.
		#
		# Need need to spam the user about news until the emerge -e system
		# because the tools aren't available to read the news item yet anyway.
		#
		# Avoid circular deps caused by the default profiles (and IUSE
		# defaults).
		echo "USE=${myuse[*]} PKG=${pkg}"
		(
			estatus "${STAGE}: emerge ${pkg}"
			unset CFLAGS CXXFLAGS
			[[ -n ${OVERRIDE_CFLAGS} ]] \
				&& export CFLAGS=${OVERRIDE_CFLAGS}
			[[ -n ${OVERRIDE_CXXFLAGS} ]] \
				&& export CXXFLAGS=${OVERRIDE_CXXFLAGS}
			PORTAGE_CONFIGROOT="${EPREFIX}" \
			PORTAGE_SYNC_STALE=0 \
			FEATURES="-news ${FEATURES}" \
			USE="${myuse[*]}" \
			emerge --color n -v --oneshot --root-deps ${opts} "${pkg}"
		)
		[[ $? -eq 0 ]] || return 1

		case ${pkg},${CHOST} in
		app-shells/bash,*-cygwin*)
			# Cygwin would resolve 'bin/bash' to 'bin/bash.exe', but
			# merging bin/bash.exe does not replace the bin/bash symlink.
			# When we can execute both bin/bash and bin/bash.exe, but
			# they are different files, then we need to drop the symlink.
			[[ -x ${EPREFIX}/bin/bash && -x ${EPREFIX}/bin/bash.exe &&
			 !    ${EPREFIX}/bin/bash  -ef  ${EPREFIX}/bin/bash.exe ]] &&
				rm -f "${EPREFIX}"/bin/bash
			;;
		esac
	done
}

bootstrap_stage2() {
	if ! type -P emerge > /dev/null ; then
		eerror "emerge not found, did you bootstrap stage1?"
		return 1
	fi

	# Find out what toolchain packages we need, and configure LDFLAGS
	# and friends.
	configure_toolchain || return 1
	configure_cflags || return 1
	export CONFIG_SHELL="${ROOT}"/tmp/bin/bash
	export CC CXX

	emerge_pkgs() {
		EPREFIX="${ROOT}"/tmp \
		STAGE=stage2 \
		do_emerge_pkgs "$@"
	}

	# bison's configure checks for perl, but doesn't use it,
	# except for tests.  Since we don't want to pull in perl at this
	# stage, fake it
	export PERL=$(which touch)
	# GCC sometimes decides that it needs to run makeinfo to update some
	# info pages from .texi files.  Obviously we don't care at this
	# stage and rather have it continue instead of abort the build
	if [[ ! -x "${ROOT}"/tmp/usr/bin/makeinfo ]]
	then
		cat > "${ROOT}"/tmp/usr/bin/makeinfo <<-EOF
		#!${ROOT}/bin/bash
		### bootstrap-prefix.sh will act on this line ###
		echo "makeinfo GNU texinfo 4.13"
		f=
		while (( \$# > 0 )); do
		a=\$1
		shift
		case \$a in
		--output=) continue ;;
		--output=*) f=\${a#--output=} ;;
		-o) f=\$1; shift;;
		esac
		done
		[[ -z \$f ]] || [[ -e \$f ]] || touch "\$f"
		EOF
		cat > "${ROOT}"/tmp/usr/bin/install-info <<-EOF
		#!${ROOT}/bin/bash
		:
		EOF
		chmod +x "${ROOT}"/tmp/usr/bin/{makeinfo,install-info}
	fi

	# on Solaris 64-bits, (at least up to 10) libgcc_s resides in a
	# non-standard location, and the compiler doesn't seem to record
	# this in rpath while it does find it, resulting in a runtime trap
	if [[ ${CHOST} == x86_64-*-solaris* || ${CHOST} == sparcv9-*-solaris* ]] ;
	then
		local libgccs64=/usr/sfw/lib/64/libgcc_s.so.1
		[[ -e ${ROOT}/tmp/usr/bin/gcc ]] || \
			cp "${libgccs64}" "${ROOT}"/tmp/usr/lib/
		# save another copy for after gcc-config gets run and removes
		# usr/lib/libgcc_s.* because new links should use the compiler
		# specific libgcc_s, but existing objs need to find this
		# libgcc_s for as long as they are around (bash->libreadline)
		LDFLAGS="${LDFLAGS} -R${ROOT}/tmp/tmp"
		mkdir -p "${ROOT}"/tmp/tmp/
		cp "${libgccs64}" "${ROOT}"/tmp/tmp/
	fi

	# Disable RAP directory hacks of binutils and gcc.  If libc.so
	# linker script provides no hint of ld-linux*.so*, ld should
	# look into its default library path.  Prefix library pathes
	# are taken care of by LDFLAGS in configure_cflags().
	export BOOTSTRAP_RAP_STAGE2=yes

	# Build a basic compiler and portage dependencies in $ROOT/tmp.
	pkgs=(
		sys-devel/gnuconfig
		sys-apps/gentoo-functions
		app-portage/elt-patches
		$([[ ${CHOST} == *-cygwin* ]] && echo dev-libs/libiconv ) # bash dependency
		sys-libs/ncurses
		sys-libs/readline
		app-shells/bash
		app-arch/xz-utils
		sys-apps/sed
		sys-apps/baselayout-prefix
		dev-libs/libffi
		sys-devel/m4
		sys-devel/flex
		sys-apps/diffutils # needed by bison-3 build system
		sys-devel/bison
		sys-devel/patch
		sys-devel/binutils-config
	)

	# Old versions of gcc has been masked.  We need gcc-4.7 to bootstrap
	# on systems without a c++ compiler.
	echo '<sys-devel/gcc-4.8' >> "${ROOT}"/tmp/etc/portage/package.unmask

	# libffi-3.0_rc0 has broken Solaris ld support, which we still
	# use at this stage (host compiler)
	[[ ${CHOST} == *-solaris* ]] && echo "=dev-libs/libffi-3.3_rc0" \
		>> "${ROOT}"/tmp/etc/portage/package.mask

	# provide active SDK link on Darwin
	if [[ ${CHOST} == *-darwin* ]] ; then
		rm -f "${ROOT}"/tmp/MacOSX.sdk
		( cd "${ROOT}"/tmp && ln -s ../MacOSX.sdk )
	fi

	# cmake has some external dependencies which require autoconf, etc.
	# unless we only build the buildtool, bug #603012
	echo "dev-util/cmake -server" >> "${ROOT}"/tmp/etc/portage/package.use

	emerge_pkgs --nodeps "${pkgs[@]}" || return 1

	# Debian multiarch supported by RAP needs ld to support sysroot.
	EXTRA_ECONF=$(rapx --with-sysroot=/) \
	emerge_pkgs --nodeps ${linker} || return 1

	for pkg in ${compiler_stage1} ; do
		# <glibc-2.5 does not understand .gnu.hash, use
		# --hash-style=both to produce also sysv hash.
		EXTRA_ECONF="--disable-bootstrap $(rapx --with-linker-hash-style=both) --with-local-prefix=${ROOT}" \
		MYCMAKEARGS="-DCMAKE_USE_SYSTEM_LIBRARY_LIBUV=OFF" \
		GCC_MAKE_TARGET=all \
		TPREFIX="${ROOT}" \
		PYTHON_COMPAT_OVERRIDE=python${PYTHONMAJMIN} \
		emerge_pkgs --nodeps ${pkg} || return 1

		if [[ "${pkg}" == *sys-devel/llvm* || ${pkg} == *sys-devel/clang* ]] ;
		then
			# we need llvm/clang ASAP for libcxx* doesn't build
			# without C++11
			[[ -x ${ROOT}/tmp/usr/bin/clang   ]] && CC=clang
			[[ -x ${ROOT}/tmp/usr/bin/clang++ ]] && CXX=clang++
		fi
	done

	if [[ ${compiler_type} == clang ]] ; then
		# We use Clang as our toolchain compiler, so we need to make
		# sure we actually use it
		mkdir -p -- "${MAKE_CONF_DIR}"
		{
			echo
			echo "# System compiler on $(uname) Prefix is Clang, do not remove this"
			echo "CC=${CHOST}-clang"
			echo "CXX=${CHOST}-clang++"
			echo "OBJC=${CHOST}-clang"
			echo "OBJCXX=${CHOST}-clang++"
			echo "BUILD_CC=${CHOST}-clang"
			echo "BUILD_CXX=${CHOST}-clang++"
		} >> "${MAKE_CONF_DIR}/0100_bootstrap_prefix_clang.conf"

		# llvm won't setup symlinks to CHOST-clang here because
		# we're in a cross-ish situation (at least according to
		# multilib.eclass -- can't blame it at this point really)
		# do it ourselves here to make the bootstrap continue
		if [[ -x "${ROOT}"/tmp/usr/bin/${CHOST}-clang ]] ; then
			( cd "${ROOT}"/tmp/usr/bin && ln -s clang ${CHOST}-clang && ln -s clang++ ${CHOST}-clang++ )
		fi
	elif ! is-rap ; then
		# make sure the EPREFIX gcc shared libraries are there
		mkdir -p "${ROOT}"/usr/${CHOST}/lib/gcc
		cp "${ROOT}"/tmp/usr/${CHOST}/lib/gcc/* "${ROOT}"/usr/${CHOST}/lib/gcc
	fi

	estatus "stage2 finished"
	einfo "stage2 successfully finished"
}

bootstrap_stage2_log() {
	bootstrap_stage2 ${@} 2>&1 | tee -a ${ROOT}/stage2.log
	local ret=${PIPESTATUS[0]}
	[[ ${ret} == 0 ]] && touch "${ROOT}/.stage2-finished"
	return ${ret}
}

bootstrap_stage3() {
	if ! type -P emerge > /dev/null ; then
		eerror "emerge not found, did you bootstrap stage1?"
		return 1
	fi

	configure_toolchain || return 1

	if [[ ${compiler_type} == clang ]] ; then
		if ! type -P clang > /dev/null ; then
			eerror "clang not found, did you bootstrap stage2?"
			return 1
		fi
	else
		if ! type -P gcc > /dev/null ; then
			eerror "gcc not found, did you bootstrap stage2?"
			return 1
		fi
	fi

	# If we resume this stage and python-exec was installed already in
	# tmp, we basically made the system unusable, so remove python-exec
	# here so we can use the python in tmp
	for pef in python{,3} python{,3}-config ; do
		rm -f "${ROOT}"/tmp/usr/bin/${pef}
		[[ ${pef} == *-config ]] && ppf=-config || ppf=
		( cd "${ROOT}"/tmp/usr/bin && ln -s python${PYTHONMAJMIN}${ppf} ${pef} )
	done

	get_libdir() {
		local l=$(portageq envvar LIBDIR_$(portageq envvar ABI) 2>/dev/null)
		[[ -z ${l} ]] && l=lib
		echo ${l}
	}

	export CONFIG_SHELL="${ROOT}"/tmp/bin/bash
	[[ ${compiler_type} == gcc ]] && \
		export CPPFLAGS="-isystem ${ROOT}/usr/include"
	export LDFLAGS="-L${ROOT}/usr/$(get_libdir)"
	[[ ${CHOST} == *-darwin* ]] || \
		LDFLAGS+=" -Wl,-rpath=${ROOT}/usr/$(get_libdir)"
	unset CC CXX

	emerge_pkgs() {
		# stage3 tools should be used first.
		# PORTAGE_TMPDIR, EMERGE_LOG_DIR, FEATURES=force-prefix are
		# needed with host portage.
		#
		# After the introduction of EAPI-7, eclasses now
		# strictly distinguish between build dependencies that
		# are binary compatible with the native build system
		# (CBUILD, BDEPEND) and with the system being built
		# (CHOST, RDEPEND).  To correctly bootstrap stage3,
		# PORTAGE_OVERRIDE_EPREFIX as BROOT is needed.
		PREROOTPATH="${ROOT}"$(echo /{,tmp/}{usr/,}{,lib/llvm/{12,11,10}/}{s,}bin | sed "s, ,:${ROOT},g") \
		EPREFIX="${ROOT}" PORTAGE_TMPDIR="${PORTAGE_TMPDIR}" \
		FEATURES="${FEATURES} force-prefix" \
		EMERGE_LOG_DIR="${ROOT}"/var/log \
		STAGE=stage3 \
		do_emerge_pkgs "$@"
	}

	with_stack_emerge_pkgs() {
		# keep FEATURES=stacked-prefix until we bump portage in stage1
		FEATURES="${FEATURES} stacked-prefix" \
		USE="${USE} prefix-stack" \
		PORTAGE_OVERRIDE_EPREFIX="${ROOT}/tmp" \
		emerge_pkgs "$@"
	}

	without_stack_emerge_pkgs() {
		PORTAGE_OVERRIDE_EPREFIX="${ROOT}" \
		emerge_pkgs "$@"
	}

	# pre_emerge_pkgs relies on stage 2 portage.
	pre_emerge_pkgs() {
		is-rap \
			&& without_stack_emerge_pkgs "$@" \
			|| with_stack_emerge_pkgs "$@"
	}

	# Some packages fail to properly depend on sys-apps/texinfo.
	# We don't really need that package, so we fake it instead,
	# explicitly emerging it later on will overwrite the fakes.
	if [[ ! -x "${ROOT}"/usr/bin/makeinfo ]]
	then
		cp -p "${ROOT}"/tmp/usr/bin/{makeinfo,install-info} "${ROOT}"/usr/bin
	fi

	# Bug 655414, 676096.
	# Portage does search it's global config using PORTAGE_OVERRIDE_EPREFIX,
	# so we need to provide it there - emerging portage itself is expected
	# to finally overwrite it.
	if [[ ! -d "${ROOT}"/usr/share/portage ]]; then
		mkdir -p "${ROOT}"/usr/share
		cp -a "${ROOT}"{/tmp,}/usr/share/portage
	fi

	if is-rap ; then
		# We need ${ROOT}/usr/bin/perl to merge glibc.
		if [[ ! -x "${ROOT}"/usr/bin/perl ]]; then
			# trick "perl -V:apiversion" check of glibc-2.19.
			echo -e "#!${ROOT}/bin/sh\necho 'apiversion=9999'" \
				> "${ROOT}"/usr/bin/perl
			chmod +x "${ROOT}"/usr/bin/perl
		fi

		# Need rsync to for linux-headers installation
		if [[ ! -x "${ROOT}"/usr/bin/rsync ]]; then
			cat > "${ROOT}"/usr/bin/rsync <<-EOF
		#!${ROOT}/bin/bash
		while (( \$# > 0 )); do
		case \$1 in
		-*) shift; continue ;;
		*) break ;;
		esac
		done
		dst="\$2"/\$(basename \$1)
		mkdir -p "\${dst}"
		cp -rv \$1/* "\${dst}"/
		EOF
			chmod +x "${ROOT}"/usr/bin/rsync
		fi

		# Tell dynamic loader the path of libgcc_s.so of stage2
		if [[ ! -f "${ROOT}"/etc/ld.so.conf.d/stage2.conf ]]; then
			mkdir -p "${ROOT}"/etc/ld.so.conf.d
			dirname $(gcc -print-libgcc-file-name) \
				> "${ROOT}"/etc/ld.so.conf.d/stage2.conf
		fi

		pkgs=(
			sys-apps/baselayout
			sys-apps/gentoo-functions
			app-portage/elt-patches
			sys-kernel/linux-headers
			sys-libs/glibc
		)

		BOOTSTRAP_RAP=yes \
		pre_emerge_pkgs --nodeps "${pkgs[@]}" || return 1
		grep -q 'apiversion=9999' "${ROOT}"/usr/bin/perl && \
			rm "${ROOT}"/usr/bin/perl
		grep -q 'esac' "${ROOT}"/usr/bin/rsync && \
			rm "${ROOT}"/usr/bin/rsync

		pkgs=(
			sys-devel/binutils-config
			sys-libs/zlib
			${linker}
		)
		# use the new dynamic linker in place of rpath from now on.
		RAP_DLINKER=$(echo "${ROOT}"/$(get_libdir)/ld*.so.[0-9])
		export LDFLAGS="-L${ROOT}/usr/$(get_libdir) -Wl,--dynamic-linker=${RAP_DLINKER}"
		BOOTSTRAP_RAP=yes \
		pre_emerge_pkgs --nodeps "${pkgs[@]}" || return 1

		# avoid circular deps with sys-libs/pam, bug#712020
		pkgs=(
			sys-apps/attr
			sys-libs/libcap
			sys-libs/libxcrypt
		)
		BOOTSTRAP_RAP=yes \
		USE="${USE} -pam" \
		pre_emerge_pkgs --nodeps "${pkgs[@]}" || return 1
	else
		pkgs=(
			sys-apps/gentoo-functions
			app-portage/elt-patches
			app-arch/xz-utils
			sys-apps/sed
			sys-apps/baselayout-prefix
			sys-devel/m4
			sys-devel/flex
			sys-devel/binutils-config
			sys-libs/zlib
			${linker}
		)

		pre_emerge_pkgs --nodeps "${pkgs[@]}" || return 1
	fi
	# remove stage2 ld so that stage3 ld is used by stage2 gcc.
	is-rap && [[ -f ${ROOT}/tmp/usr/${CHOST}/bin/ld ]] && \
		mv ${ROOT}/tmp/usr/${CHOST}/bin/ld{,.stage2}

	# On some hosts, gcc gets confused now when it uses the new linker,
	# see for instance bug #575480.  While we would like to hide that
	# linker, we can't since we want the compiler to pick it up.
	# Therefore, inject some kludgy workaround, for deps like gmp that
	# use c++
	[[ ${CHOST} != *-darwin* ]] && ! is-rap && export CXX="${CHOST}-g++ -lgcc_s"

	# Clang unconditionally requires python, the eclasses are really not
	# setup for a scenario where python doesn't live in the target
	# prefix and no helpers are available
	( cd "${ROOT}"/usr/bin && test ! -e python && \
		ln -s "${ROOT}"/tmp/usr/bin/python${PYTHONMAJMIN} )
	# in addition, avoid collisions
	rm -Rf "${ROOT}"/tmp/usr/lib/python${PYTHONMAJMIN}/site-packages/clang

	# Try to get ourself out of the mud, bug #575324
	EXTRA_ECONF="--disable-compiler-version-checks $(rapx '--disable-lto --disable-bootstrap')" \
	GCC_MAKE_TARGET=$(rapx all) \
	MYCMAKEARGS="-DCMAKE_USE_SYSTEM_LIBRARY_LIBUV=OFF" \
	PYTHON_COMPAT_OVERRIDE=python${PYTHONMAJMIN} \
	pre_emerge_pkgs --nodeps ${compiler} || return 1

	# Undo libgcc_s.so path of stage2
	# Now we have the compiler right there
	unset CXX CPPFLAGS LDFLAGS

	rm -f "${ROOT}"/etc/ld.so.conf.d/stage2.conf

	# need special care, it depends on texinfo, #717786
	pre_emerge_pkgs --nodeps sys-apps/gawk || return 1

	( cd "${ROOT}"/usr/bin && test ! -e python && rm -f python${PYTHONMAJMIN} )
	# Use $ROOT tools where possible from now on.
	if [[ $(readlink "${ROOT}"/bin/sh) == "${ROOT}/tmp/"* ]] ; then
		rm -f "${ROOT}"/bin/sh
		ln -s bash "${ROOT}"/bin/sh
	fi

	# Start using apps from new target
	export PREROOTPATH="${ROOT}/usr/bin:${ROOT}/bin"

	# Get a sane bash, overwriting tmp symlinks
	pre_emerge_pkgs "" "app-shells/bash" || return 1

	# now we have a shell right there
	unset CONFIG_SHELL

	# Build portage and dependencies.
	pkgs=(
		sys-apps/coreutils
		sys-apps/findutils
		app-arch/gzip
		app-arch/tar
		sys-apps/grep
		sys-devel/make
		sys-apps/file
		app-admin/eselect
		$( [[ ${CHOST} == *-cygwin* ]] && echo sys-libs/cygwin-crypt )
	)

	# For grep we need to do a little workaround as we might use llvm-3.4
	# here, which doesn't necessarily grok the system headers on newer
	# OSX, confusing the buildsystem
	ac_cv_c_decl_report=warning \
	TIME_T_32_BIT_OK=yes \
	pre_emerge_pkgs "" "${pkgs[@]}" || return 1

	if [[ ! -x "${ROOT}"/sbin/openrc-run ]]; then
		echo "We need openrc-run at ${ROOT}/sbin to merge rsync." \
			> "${ROOT}"/sbin/openrc-run
		chmod +x "${ROOT}"/sbin/openrc-run
	fi

	pkgs=(
		virtual/os-headers
		sys-devel/gettext
		sys-apps/portage
	)

	without_stack_emerge_pkgs "" "${pkgs[@]}" || return 1

	# Switch to the proper portage.
	hash -r

	# Update the portage tree.
	estatus "stage3: updating Portage tree"
	treedate=$(date -f "${PORTDIR}"/metadata/timestamp +%s)
	nowdate=$(date +%s)
	[[ ( ! -e ${PORTDIR}/.unpacked ) && \
		$((nowdate - (60 * 60 * 24))) -lt ${treedate} ]] || \
	if [[ ${OFFLINE_MODE} ]]; then
		# --keep used ${DISTDIR}, which make it easier to download a
		# snapshot beforehand
		emerge-webrsync --keep || return 1
	else
		emerge --color n --sync || emerge-webrsync || return 1
	fi

	# Avoid installing git or encryption just for fun while completing @system
	export USE="-git -crypt"

	# Portage should figure out itself what it needs to do, if anything.
	einfo "running emerge -uDNv system"
	estatus "stage3: emerge -uDNv system"
	unset CFLAGS CXXFLAGS CPPFLAGS
	emerge --color n -uDNv system || return 1

	# Remove anything that we don't need (compilers most likely)
	einfo "running emerge --depclean"
	estatus "stage3: emerge --depclean"
	emerge --color n --depclean

	# "wipe" mtimedb such that the resume list is proper after this stage
	# (--depclean may fail, which is ok)
	sed -i -e 's/resume/cleared/' "${ROOT}"/var/cache/edb/mtimedb

	estatus "stage3 finished"
	einfo "stage3 successfully finished"
}

bootstrap_stage3_log() {
	bootstrap_stage3 ${@} 2>&1 | tee -a ${ROOT}/stage3.log
	local ret=${PIPESTATUS[0]}
	[[ ${ret} == 0 ]] && touch "${ROOT}/.stage3-finished"
	return ${ret}
}

set_helper_vars() {
	CXXFLAGS="${CXXFLAGS:-${CFLAGS}}"
	export PORTDIR=${PORTDIR:-"${ROOT}/var/db/repos/gentoo"}
	export DISTDIR=${DISTDIR:-"${ROOT}/var/cache/distfiles"}
	PORTAGE_TMPDIR=${PORTAGE_TMPDIR:-${ROOT}/var/tmp}
	MAKE_CONF_DIR="${ROOT}/etc/portage/make.conf/"
	DISTFILES_URL=${DISTFILES_URL:-"http://dev.gentoo.org/~grobian/distfiles"}
	GNU_URL=${GNU_URL:="http://ftp.gnu.org/gnu"}
	DISTFILES_G_O="http://distfiles.prefix.bitzolder.nl"
	DISTFILES_PFX="http://distfiles.prefix.bitzolder.nl/prefix"
	GENTOO_MIRRORS=${GENTOO_MIRRORS:="http://distfiles.gentoo.org"}
	SNAPSHOT_HOST=$(rapx ${DISTFILES_G_O} http://rsync.prefix.bitzolder.nl)
	SNAPSHOT_URL=${SNAPSHOT_URL:-"${SNAPSHOT_HOST}/snapshots"}
	GCC_APPLE_URL="http://www.opensource.apple.com/darwinsource/tarballs/other"

	export MAKE CONFIG_SHELL
}

bootstrap_interactive() {
	# TODO should immediately die on platforms that we know are
	# impossible due to extremely hard dependency chains
	# (NetBSD/OpenBSD)

	cat <<"EOF"


                                             .
       .vir.                                d$b
    .d$$$$$$b.    .cd$$b.     .d$$b.   d$$$$$$$$$$$b  .d$$b.      .d$$b.
    $$$$( )$$$b d$$$()$$$.   d$$$$$$$b Q$$$$$$$P$$$P.$$$$$$$b.  .$$$$$$$b.
    Q$$$$$$$$$$B$$$$$$$$P"  d$$$PQ$$$$b.   $$$$.   .$$$P' `$$$ .$$$P' `$$$
      "$$$$$$$P Q$$$$$$$b  d$$$P   Q$$$$b  $$$$b   $$$$b..d$$$ $$$$b..d$$$
     d$$$$$$P"   "$$$$$$$$ Q$$$     Q$$$$  $$$$$   `Q$$$$$$$P  `Q$$$$$$$P
    $$$$$$$P       `"""""   ""        ""   Q$$$P     "Q$$$P"     "Q$$$P"
    `Q$$P"                                  """

             Welcome to the Gentoo Prefix interactive installer!


    I will attempt to install Gentoo Prefix on your system.  To do so, I'll
    ask  you some questions first.    After that,  you'll have to  practise
    patience as your computer and I try to figure out a way to get a lot of
    software  packages  compiled.    If everything  goes according to plan,
    you'll end up with what we call  "a Prefix install",  but by that time,
    I'll tell you more.


EOF
	[[ ${TODO} == 'noninteractive' ]] && ans=yes ||
	read -p "Do you want me to start off now? [Yn] " ans
	case "${ans}" in
		[Yy][Ee][Ss]|[Yy]|"")
			: ;;
		*)
			echo "Right.  Aborting..."
			exit 1
			;;
	esac

	if [[ ${CHOST} == *-cygwin* ]]; then
		if [[ -r /var/run/cygfork/. ]]; then
			cat << EOF

Whoah there, I've found the /var/run/cygfork/ directory.  This makes
me believe you have a working fork() in your Cygwin instance, which
seems you really know what I can do for you when you help me out!
EOF
		else
			echo
			[[ ${TODO} == 'noninteractive' ]] && ans="yes" ||
			read -p "Are you really, really sure what you want me to do for you? [no] " ans
			case "${ans}" in
			[Yy][Ee][Ss]) ;;
			*)
				cat << EOF

Puh, I'm glad you agree with me here, thanks!
EOF
				exit 1
				;;
			esac

			cat << EOF

Well...
EOF
			[[ ${TODO} == 'noninteractive' ]] || sleep 1
			cat << EOF

Nope, seems you aren't: This is Windows after all,
which I'm traditionally incompatible with!
EOF
			[[ ${TODO} == 'noninteractive' ]] || sleep 1
			cat << EOF

But wait, there might be help!
EOF
			[[ ${TODO} == 'noninteractive' ]] || sleep 1
			cat << EOF

Once upon a time there was a guy, probably as freaky as you, my master.
And whether you believe or not, he has been able to do something useful
to Windows, in that he completed a piece of code to support myself.

Although you already use that piece of code - yes, it's called Cygwin,
you seem to not use this freaky guy's completions yet.

To help me out of the incompatibility hole, please read and follow
https://wiki.gentoo.org/wiki/Prefix/Cygwin first.

But remember that you won't get support from upstream Cygwin now.
EOF
		  exit 1
		fi
	fi

	if [[ ${UID} == 0 ]] ; then
		cat << EOF

Hmmm, you appear to be root, or at least someone with UID 0.  I really
don't like that.  The Gentoo Prefix people really discourage anyone
running Gentoo Prefix as root.  As a matter of fact, I'm just refusing
to help you any further here.
If you insist, you'll have go without my help, or bribe me.
EOF
		exit 1
	fi
	echo
	echo "It seems to me you are '${USER:-$(whoami 2> /dev/null)}' (${UID}), that looks cool to me."

	# In case $ROOT were specified as $1, use it
	[[ -z "${EPREFIX}" ]] && EPREFIX="${ROOT}"

	echo
	echo "I'm going to check for some variables in your environment now:"
	local flag dvar badflags=
	for flag in \
		ASFLAGS \
		CFLAGS \
		CPPFLAGS \
		CXXFLAGS \
		DYLD_LIBRARY_PATH \
		GREP_OPTIONS \
		LDFLAGS \
		LD_LIBRARY_PATH \
		LIBPATH \
		PERL_MM_OPT \
		PERL5LIB \
		PKG_CONFIG_PATH \
		PYTHONPATH \
		ROOT \
		CPATH \
		LIBRARY_PATH \
	; do
		# starting on purpose a shell here iso ${!flag} because I want
		# to know if the shell initialisation files trigger this
		# note that this code is so complex because it handles both
		# C-shell as well as *sh
		dvar="echo \"((${flag}=\${${flag}}))\""
		dvar="$(echo "${dvar}" | env -i HOME=$HOME $SHELL -l 2>/dev/null)"
		if [[ ${dvar} == *"((${flag}="?*"))" ]] ; then
			badflags="${badflags} ${flag}"
			dvar=${dvar#*((${flag}=}
			dvar=${dvar%%))*}
			echo "  uh oh, ${flag}=${dvar} :("
		else
			echo "  it appears ${flag} is not set :)"
		fi
		# unset for the current environment
		unset ${flag}
	done
	if [[ -n ${badflags} ]] ; then
		cat << EOF

Ahem, your shell environment contains some variables I'm allergic to:
 ${badflags}
These flags can and will influence the way in which packages compile.
In fact, they have a long standing tradition to break things.  I really
prefer to be on my own here.  So please make sure you disable these
environment variables in your shell initialisation files.  After you've
done that, you can run me again.
EOF
		exit 1
	fi
	echo
	echo "I'm excited!  Seems we can finally do something productive now."

	cat << EOF

Ok, I'm going to do a little bit of guesswork here.  Thing is, your
machine appears to be identified by CHOST=${CHOST}.
EOF
	case "${CHOST}" in
		powerpc*|ppc*|sparc*)
			cat << EOF

To me, it seems to be a big-endian machine.  I told you before you need
patience, but with your machine, regardless how many CPUs you have, you
need some more.  Context switches are just expensive, and guess what
fork/execs result in all the time.  I'm going to make it even worse for
you, configure and make typically are fork/exec bombs.
I'm going to assume you're actually used to having patience with this
machine, which is good, because I really love a box like yours!
EOF
			;;
	esac

	# eventually the user does know where to find a compiler
	[[ ${TODO} == 'noninteractive' ]] &&
	usergcc=$(type -P gcc 2>/dev/null)

	# the standard path we want to start with, override anything from
	# the user on purpose
	PATH="/usr/bin:/bin"
	# don't exclude the path to bash if it isn't in a standard location
	type -P bash > /dev/null || PATH="${BASH%/bash}:${PATH}"
	case "${CHOST}" in
		*-solaris*)
			cat << EOF

Ok, this is Solaris, or a derivative like OpenSolaris or OpenIndiana.
Sometimes, useful tools necessary at this stage are hidden.  I'm going
to check if that's the case for your system too, and if so, add those
locations to your PATH.
EOF
			# could do more "smart" CHOST deductions here, but brute
			# force is most likely as quick, but simpler
			[[ -d /usr/sfw/bin ]] \
				&& PATH="${PATH}:/usr/sfw/bin"
			[[ -d /usr/sfw/i386-sun-solaris${CHOST##*-solaris}/bin ]] \
				&& PATH="${PATH}:/usr/sfw/i386-sun-solaris${CHOST##*-solaris}/bin"
			[[ -d /usr/sfw/sparc-sun-solaris${CHOST##*-solaris}/bin ]] \
				&& PATH="${PATH}:/usr/sfw/sparc-sun-solaris${CHOST##*-solaris}/bin"
			# OpenIndiana 151a5
			[[ -d /usr/gnu/bin ]] && PATH="${PATH}:/usr/gnu/bin"
			# SmartOS
			[[ -d /opt/local/gcc7/bin ]] && PATH="${PATH}:/opt/local/gcc7/bin"
			[[ -d /opt/local/gcc47/bin ]] && PATH="${PATH}:/opt/local/gcc47/bin"
			;;
		*-darwin1*)
			# Apple ships a broken clang by default, fun!
			[[ -e /Library/Developer/CommandLineTools/usr/bin/clang ]] \
				&& PATH="/Library/Developer/CommandLineTools/usr/bin:${PATH}"
			;;
		*-cygwin*)
			# Keep some Windows
			PATH+=":$(cygpath -S):$(cygpath -W)"
			;;
	esac

	# TODO: should we better use cc here? or check both?
	if ! type -P gcc > /dev/null && ! type -P clang > /dev/null ; then
		case "${CHOST}" in
			*-darwin*)
				cat << EOF

Uh oh... a Mac OS X system, but without compiler.  You must have
forgotten to install Xcode tools.  If your Mac didn't come with an
install DVD (pre Lion) you can find it in the Mac App Store, or download
the Xcode command line tools from Apple Developer Connection.  If you
did get a CD/DVD with your Mac, there is a big chance you can find Xcode
on it, and install it right away.
Please do so, and try me again!
EOF
				exit 1
				;;
			*-solaris2.[789]|*-solaris2.10)
				cat << EOF

Yikes!  Your Solaris box doesn't come with gcc in /usr/sfw/blabla/bin?
What good is it to me then?  I can't find a compiler!  I'm afraid
you'll have to find a way to install the Sun FreeWare tools somehow, is
it on the Companion disc perhaps?
See me again when you figured it out.
EOF
				exit 1
				;;
			*-solaris*)
				SOLARIS_RELEASE=$(head -n1 /etc/release)
				if [[ ${SOLARIS_RELEASE} == *"Oracle Solaris"* ]] ; then
					cat << EOF
Seems like you have installed Oracle Solaris ${SOLARIS_RELEASE}.
I suppose you have solaris publisher set.  If not, use:
  pkg set-publisher -p http://pkg.oracle.com/solaris/release
You need to install some necessary packages:
  pkg install developer/gcc-45 system/header
In the meanwhile, I'll wait here until you run me again, with a compiler.
EOF
				else
					cat << EOF

Sigh.  This is OpenSolaris or OpenIndiana?  I can't tell the difference
without looking more closely.  What I DO know, is that there is no
compiler, at least not where I was just looking, so how do we continue
from here, eh?  I just think you didn't install one.  I know it can be
tricky on OpenIndiana, for instance, so won't blame you.  In case you're
on OpenIndiana, I'll help you a bit.  Perform the following as
super-user:
  pkg install developer/gnu system/header
In the meanwhile, I'll wait here until you run me again, with a compiler.
EOF
				fi
				exit 1
				;;
			*)
				cat << EOF

Well, well... let's make this painful situation as short as it can be:
you don't appear to have a compiler around for me to play with.
Since I like your PATH to be as minimal as possible, I threw away
everything you put in it, and started from scratch.  Perhaps, the almost
impossible happened that I was wrong in doing so.
Ok, I'll give you a chance.  You can now enter what you think is
necessary to add to PATH for me to find a compiler.  I start off with
PATH=${PATH} and will add anything you give me here.
EOF
				[[ ${TODO} == 'noninteractive' ]] && ans="${usergcc%/gcc}" ||
				read -p "Where can I find your compiler? [] " ans
				case "${ans}" in
					"")
						: ;;
					*)
						PATH="${PATH}:${ans}"
						;;
				esac
				if ! type -P gcc > /dev/null ; then
					cat << EOF

Are you sure you have a compiler?  I didn't find one.  I think you
better first go get one, then run me again.
EOF
					exit 1
				else
					echo
					echo "Pfff, ok, it seems you were right.  Can we move on now?"
				fi
			;;
		esac
	else
		echo
		echo "Great!  You appear to have a compiler in your PATH"
	fi

	if type -P xcode-select > /dev/null ; then
		if [[ -d /usr/include ]] ; then
			# if we have /usr/include we're on an older system
			if [[ ${CHOST} == powerpc* ]]; then
				# ancient Xcode (3.0/3.1)
				cat << EOF

Ok, this is an old system, let's just try and see what happens.
EOF
			elif [[ $(xcode-select -p) != */CommandLineTools ]] ; then
				# to an extent, bug #564814 and bug #562800
				cat << EOF

Your xcode-select is not set to CommandLineTools.  This prevents builds
from succeeding.  Switch to command line tools for the bootstrap to
continue.  Please execute:
  xcode-select -s /Library/Developer/CommandLineTools
and try running me again.
EOF
			fi
		else
			# let's see if we have an xcode install
			if [[ ! -e $(xcrun -f gcc 2>/dev/null) ]] ; then
				cat << EOF

You don't have Xcode installed, or xcode-select isn't pointing to a
valid install.  Try resetting it using:
  sudo xcode-select -r
and try running me again.
EOF
			fi
		fi
	fi
	echo
	local ncpu=
	case "${CHOST}" in
		*-cygwin*)
			ncpu=$(cmd /D /Q /C 'echo %NUMBER_OF_PROCESSORS%' | tr -d "\\r") ;;
		*-darwin*)
			ncpu=$(/usr/sbin/sysctl -n hw.ncpu) ;;
		*-freebsd* | *-openbsd*)
			ncpu=$(/sbin/sysctl -n hw.ncpu) ;;
		*-solaris*)
			ncpu=$(/usr/sbin/psrinfo | wc -l) ;;
		*-linux-gnu*)
			ncpu=$(cat /proc/cpuinfo | grep processor | wc -l) ;;
		*)
			ncpu=1 ;;
	esac
	# get rid of excess spaces (at least Solaris wc does)
	ncpu=$((ncpu + 0))
	# Suggest usage of 100% to 60% of the available CPUs in the range
	# from 1 to 14.  We limit to no more than 8, since we easily flood
	# the bus on those heavy-core systems and only slow down in that
	# case anyway.
	local tcpu=$((ncpu / 2 + 1))
	[[ ${tcpu} -gt 8 ]] && tcpu=8
	[[ -n ${USE_CPU_CORES} ]] && tcpu=${USE_CPU_CORES}
	cat << EOF

I did my utmost best, and found that you have ${ncpu} cpu cores.  If
this looks wrong to you, you can happily ignore me.  Based on the number
of cores you have, I came up with the idea of parallelising compilation
work where possible with ${tcpu} parallel make threads.  If you have no
clue what this means, you should go with my excellent default I've
chosen below, really!
EOF
	[[ ${TODO} == 'noninteractive' ]] && ans="" ||
	read -p "How many parallel make jobs do you want? [${tcpu}] " ans
	case "${ans}" in
		"")
			MAKEOPTS="-j${tcpu}"
			;;
		*)
			if [[ ${ans} -le 0 ]] ; then
				echo
				echo "You should have entered a non-zero integer number, obviously..."
				exit 1
			elif [[ ${ans} -gt ${tcpu} && ${tcpu} -ne 1 ]] ; then
				if [[ ${ans} -gt ${ncpu} ]] ; then
					cat << EOF

Want to push it very hard?  I already feel sorry for your poor box with
its mere ${ncpu} cpu cores.
EOF
				elif [[ $((ans - tcpu)) -gt 1 ]] ; then
					cat << EOF

So you think you can stress your system a bit more than my extremely
well thought out formula suggested you?  Hmmpf, I'll take it you know
what you're doing then.
EOF
					sleep 1
					echo "(are you?)"
				fi
			fi
			MAKEOPTS="-j${ans}"
			;;
	esac
	export MAKEOPTS

	#32/64 bits, multilib
	local candomultilib=no
	local t64 t32
	case "${CHOST}" in
		*86*-darwin9|*86*-darwin1[012345])
			# PPC/Darwin only works in 32-bits mode, so this is Intel
			# only, and only starting from Leopard (10.5, darwin9)
			# with Big Sur (11.0, darwin20) we have x64 or arm64 only
			candomultilib=yes
			t64=x86_64-${CHOST#*-}
			t32=i686-${CHOST#*-}
			;;
		*-solaris*)
			# Solaris is a true multilib system from as long as it does
			# 64-bits, we only need to know if the CPU we use is capable
			# of doing 64-bits mode
			[[ $(/usr/bin/isainfo | tr ' ' '\n' | wc -l) -ge 2 ]] \
				&& candomultilib=yes
			if [[ ${CHOST} == sparc* ]] ; then
				t64=sparcv9-${CHOST#*-}
				t32=sparc-${CHOST#*-}
			else
				t64=x86_64-${CHOST#*-}
				t32=i386-${CHOST#*-}
			fi
			;;
		# Even though multilib on Linux is often supported in some way,
		# it's hardly ever installed by default (it seems)
		# Since it's non-trivial to figure out if such system (binary
		# packages can report to be multilib, but lack all necessary
		# libs) is truely multilib capable, we don't bother here.  The
		# user can override if he/she is really convinced the system can
		# do it.
	esac
	if [[ ${candomultilib} == yes ]] ; then
		cat << EOF

Your system appears to be a multilib system, that is in fact also
capable of doing multilib right here, right now.  Multilib means
something like "being able to run multiple kinds of binaries".  The most
interesting kind for you now is 32-bits versus 64-bits binaries.  I can
create both a 32-bits as well as a 64-bits Prefix for you, but do you
actually know what I'm talking about here?  If not, just accept the
default here.  Honestly, you don't want to change it if you can't name
one advantage of 64-bits over 32-bits other than that 64 is a higher
number and when you buy a car or washing machine, you also always choose
the one with the highest number.
EOF
		[[ ${TODO} == 'noninteractive' ]] && ans="" ||
		case "${CHOST}" in
			x86_64-*|sparcv9-*)  # others can't do multilib, so don't bother
				# 64-bits native
				read -p "How many bits do you want your Prefix to target? [64] " ans
				;;
			*)
				# 32-bits native
				read -p "How many bits do you want your Prefix to target? [32] " ans
				;;
		esac
		case "${ans}" in
			"")
				: ;;
			32)
				CHOST=${t32}
				;;
			64)
				CHOST=${t64}
				;;
			*)
				cat << EOF

${ans}? Yeah Right(tm)!  You obviously don't know what you're talking
about, so I'll take the default instead.
EOF
				;;
		esac
	fi
	export CHOST

	# Figure out if we are bootstrapping from an existing Gentoo
	# It can be forced by setting HOST_GENTOO_EROOT manually
	local t_GENTOO_EROOT=$(env -u EPREFIX portageq envvar EROOT 2> /dev/null)
	if [[ ! -d ${HOST_GENTOO_EROOT} && -d ${t_GENTOO_EROOT} ]]; then
		cat <<EOF

Sweet, a Gentoo Penguin is found at ${t_GENTOO_EROOT}.  Hey, you are
really a Gentoo lover, aren't you?  Me too!  By leveraging the existing
portage, we can save a lot of time."
EOF
		[[ ${TODO} == 'noninteractive' ]] && ans=no ||
		read -p "  Do you want me to take the shortcut? [yN] " ans
		case "${ans}" in
			[Yy][Ee][Ss]|[Yy])
				echo "Good!"
				export HOST_GENTOO_EROOT="${t_GENTOO_EROOT}"
				: ;;
			*)
				echo "Fine, I will bootstrap from scratch."
				;;
		esac
	fi

	# The experimental support for Stable Prefix.
	# When expanding this to other CHOSTs, don't forget to update
	# make.conf generation in bootstrap_setup().
	# TODO: Consider at some point removing the ~ARCH override from
	# profiles/features/prefix/standalone/make.defaults.
	# https://bugs.gentoo.org/759424
	if is-rap ; then
		if [[ "${CHOST}" == x86_64-pc-linux-gnu ]]; then
			cat <<EOF

Normally I can only give you ~amd64 packages, and you would be exposed
to all the bugs of the newest untested software.  Well, ok, sometimes
it also has new features, but who needs those.  But as you are a VIP
customer who uses Linux on x86_64, I have a one-time offer for you!
I can limit your Prefix to use only packages keyworded for stable amd64
by default.  Of course, you can still enable testing ~amd64 for
the packages you want, when the need arises.
EOF
			[[ ${TODO} == 'noninteractive' ]] && ans=yes ||
			read -p "  Do you want to use stable Prefix? [Yn] " ans
			case "${ans}" in
				[Yy][Ee][Ss]|[Yy]|"")
					echo "Okay, I'll disable ~amd64 by default."
					export STABLE_PREFIX="yes"
					;;
				*)
					echo "Fine, I will not disable ~amd64, no problem."
					;;
			esac
		fi
	fi

	# choose EPREFIX, we do this last, since we have to actually write
	# to the filesystem here to check that the EPREFIX is sane
	cat << EOF

Each and every Prefix has a home.  That is, a place where everything is
supposed to be in.  That place must be fully writable by you (duh), but
should also be able to hold some fair amount of data and preferably be
reasonably fast.  In terms of space, I advise something around 2GiB
(it's less if you're lucky).  I suggest a reasonably fast place because
we're going to compile a lot, and that generates a fair bit of IO.  If
some networked filesystem like NFS is the only option for you, then
you're just going to have to wait a fair bit longer.
This place which is your Prefix' home, is often referred to by a
variable called EPREFIX.
EOF
	while true ; do
		if [[ -z ${EPREFIX} ]] ; then
			# Make the default for Mac users a bit more "native feel"
			[[ ${CHOST} == *-darwin* ]] \
				&& EPREFIX=$HOME/Gentoo \
				|| EPREFIX=$HOME/gentoo
		fi
		echo
		[[ ${TODO} == 'noninteractive' ]] && ans= ||
		read -p "What do you want EPREFIX to be? [$EPREFIX] " ans
		case "${ans}" in
			"")
				: ;;
			/*)
				EPREFIX=${ans}
				;;
			*)
				echo
				echo "EPREFIX must be an absolute path!"
				[[ ${TODO} == 'noninteractive' ]] && exit 1
				EPREFIX=
				continue
				;;
		esac
		if [[ ! -d ${EPREFIX} ]] && ! mkdir -p "${EPREFIX}"/. ; then
			echo
			echo "It seems I cannot create ${EPREFIX}."
			[[ ${TODO} == 'noninteractive' ]] && exit 1
			echo "I'll forgive you this time, try again."
			EPREFIX=
			continue
		fi
		#readlink -f would not work on darwin, so use bash builtins
		local realEPREFIX="$(cd "$EPREFIX"; pwd -P)"
		if [[ -z ${I_KNOW_MY_GCC_WORKS_FINE_WITH_SYMLINKS} && ${EPREFIX} != ${realEPREFIX} ]]; then
			echo
			echo "$EPREFIX contains a symlink, which will make the merge of gcc"
			echo "imposible, use '${realEPREFIX}' instead or"
			echo "export I_KNOW_MY_GCC_WORKS_FINE_WITH_SYMLINKS='hell yeah'"
			[[ ${TODO} == 'noninteractive' ]] && exit 1
			echo "Have another try."
			EPREFIX="${realEPREFIX}"
			continue
		fi
		if ! touch "${EPREFIX}"/.canihaswrite >& /dev/null ; then
			echo
			echo "I cannot write to ${EPREFIX}!"
			[[ ${TODO} == 'noninteractive' ]] && exit 1
			echo "You want some fun, but without me?  Try another location."
			EPREFIX=
			continue
		fi
		# GNU and BSD variants of stat take different arguments (and
		# format specifiers are not equivalent)
		case "${CHOST}" in
			*-darwin* | *-freebsd* | *-openbsd*) STAT='stat -f %u/%g' ;;
			*)                                   STAT='stat -c %U/%G' ;;
		esac

		if [[ $(${STAT} "${EPREFIX}"/.canihaswrite) != \
			$(${STAT} "${EPREFIX}") ]] ;
		then
			echo
			echo "The $EPREFIX directory has different ownership than expected."
			echo "Ensure the directory is owned (user and group) by your"
			echo "primary ids"
			EPREFIX=
			continue
		fi
		# don't really expect this one to fail
		rm -f "${EPREFIX}"/.canihaswrite || exit 1
		# location seems ok
		break
	done
	export PATH="$EPREFIX/usr/bin:$EPREFIX/bin:$EPREFIX/tmp/usr/bin:$EPREFIX/tmp/bin:$EPREFIX/tmp/usr/local/bin:${PATH}"

	cat << EOF

OK!  I'm going to give it a try, this is what I have collected sofar:
  EPREFIX=${EPREFIX}
  CHOST=${CHOST}
  PATH=${PATH}
  MAKEOPTS=${MAKEOPTS}

I'm now going to make an awful lot of noise going through a sequence of
stages to make your box as groovy as I am myself, setting up your
Prefix.  In short, I'm going to run stage1, stage2, stage3, followed by
emerge -e system.  If any of these stages fail, both you and me are in
deep trouble.  So let's hope that doesn't happen.
EOF
	echo
	[[ ${TODO} == 'noninteractive' ]] && ans="" ||
	read -p "Type here what you want to wish me [luck] " ans
	if [[ -n ${ans} && ${ans} != "luck" ]] ; then
		echo "Huh?  You're not serious, are you?"
		sleep 3
	fi
	echo

	if [[ -d ${HOST_GENTOO_EROOT} ]]; then
		if ! [[ -x ${EPREFIX}/tmp/usr/lib/portage/bin/emerge ]] && ! ${BASH} ${BASH_SOURCE[0]} "${EPREFIX}" stage_host_gentoo ; then
			# stage host gentoo fail
			cat << EOF

I tried running
  ${BASH} ${BASH_SOURCE[0]} "${EPREFIX}" stage_host_gentoo
but that failed :(  I have no clue, really.  Please find friendly folks
in #gentoo-prefix on irc.gentoo.org, gentoo-alt@lists.gentoo.org mailing list,
or file a bug at bugs.gentoo.org under Gentoo/Alt, Prefix Support.
Sorry that I have failed you master.  I shall now return to my humble cave.
EOF
			exit 1
		fi
	fi
	
	# because we unset ROOT from environment above, and we didn't set
	# ROOT as argument in the script, we set ROOT here to the EPREFIX we
	# just harvested
	ROOT="${EPREFIX}"
	set_helper_vars

	if ! [[ -e ${EPREFIX}/.stage1-finished ]] && ! bootstrap_stage1_log ; then
		# stage 1 fail
		cat << EOF

I tried running
  bootstrap_stage1_log
but that failed :(  I have no clue, really.  Please find friendly folks
in #gentoo-prefix on irc.gentoo.org, gentoo-alt@lists.gentoo.org mailing list,
or file a bug at bugs.gentoo.org under Gentoo/Alt, Prefix Support.
Sorry that I have failed you master.  I shall now return to my humble cave.
You can find a log of what happened in ${EPREFIX}/stage1.log
EOF
		exit 1
	fi

	[[ ${STOP_BOOTSTRAP_AFTER} == stage1 ]] && exit 0

	unset ROOT

	# stage1 has set a profile, which defines CHOST, so unset any CHOST
	# we've got here to avoid cross-compilation due to slight
	# differences caused by our guessing vs. what the profile sets.
	# This happens at least on 32-bits Darwin, with i386 and i686.
	# https://bugs.gentoo.org/show_bug.cgi?id=433948
	unset CHOST
	export CHOST=$(portageq envvar CHOST)

	# after stage1 and stage2 we should have a bash of our own, which
	# is preferable over the host-provided one, because we know it can
	# deal with the bash-constructs we use in stage3 and onwards
	hash -r

	local https_needed=no
	if ! [[ -e ${EPREFIX}/.stage2-finished ]] \
		&& ! ${BASH} ${BASH_SOURCE[0]} "${EPREFIX}" stage2_log ; then
		# stage 2 fail
		cat << EOF

Odd!  Running
  ${BASH} ${BASH_SOURCE[0]} "${EPREFIX}" stage2
failed! :(  Details might be found in the build log:
EOF
		for log in "${EPREFIX}"{/tmp,}/var/tmp/portage/*/*/temp/build.log ; do
			[[ -e ${log} ]] || continue
			echo "  ${log}"
			grep -q "HTTPS support not compiled in" "${log}" && https_needed=yes
		done
		[[ -e ${log} ]] || echo "  (no build logs found?!?)"
		if [[ ${https_needed} == "yes" ]] ; then
			cat << EOF
It seems one of your logs indicates a download problem due to missing
HTTPS support.  If this appears to be the problem for real, you can work
around this for now by downloading the file manually and placing it in
  "${DISTDIR}"
I will find it when you run me again.  If this is NOT the problem, then
EOF
		fi
		cat << EOF
I have no clue, really.  Please find friendly folks in #gentoo-prefix on
irc.gentoo.org, gentoo-alt@lists.gentoo.org mailing list, or file a bug
at bugs.gentoo.org under Gentoo/Alt, Prefix Support.
Remember you might find some clues in ${EPREFIX}/stage2.log
EOF
		exit 1
	fi

	[[ ${STOP_BOOTSTRAP_AFTER} == stage2 ]] && exit 0

	# new bash
	hash -r

	if ! [[ -e ${EPREFIX}/.stage3-finished ]] \
		&& ! bash ${BASH_SOURCE[0]} "${EPREFIX}" stage3_log ; then
		# stage 3 fail
		hash -r  # previous cat (tmp/usr/bin/cat) may have been removed
		cat << EOF

Hmmmm, I was already afraid of this to happen.  Running
  $(type -P bash) ${BASH_SOURCE[0]} "${EPREFIX}" stage3
somewhere failed :(  Details might be found in the build log:
EOF
		for log in "${EPREFIX}"{/tmp,}/var/tmp/portage/*/*/temp/build.log ; do
			[[ -e ${log} ]] || continue
			echo "  ${log}"
			grep -q "HTTPS support not compiled in" "${log}" && https_needed=yes
		done
		[[ -e ${log} ]] || echo "  (no build logs found?!?)"
		if [[ ${https_needed} == "yes" ]] ; then
			cat << EOF
It seems one of your logs indicates a download problem due to missing
HTTPS support.  If this appears to be the problem for real, you can work
around this for now by downloading the file manually and placing it in
  "${DISTDIR}"
I will find it when you run me again.  If this is NOT the problem, then
EOF
		fi
		cat << EOF
I have no clue, really.  Please find friendly folks in #gentoo-prefix on
irc.gentoo.org, gentoo-alt@lists.gentoo.org mailing list, or file a bug
at bugs.gentoo.org under Gentoo/Alt, Prefix Support.  This is most
inconvenient, and it crushed my ego.  Sorry, I give up.
Should you want to give it a try, there is ${EPREFIX}/stage3.log
EOF
		exit 1
	fi

	[[ ${STOP_BOOTSTRAP_AFTER} == stage3 ]] && exit 0

	local cmd="emerge -v -e system"
	if [[ -e ${EPREFIX}/var/cache/edb/mtimedb ]] && \
		grep -q resume "${EPREFIX}"/var/cache/edb/mtimedb ;
	then
		cmd="emerge -v --resume"
	fi
	einfo "running ${cmd}"
	if ${cmd} ; then
		# Now, after 'emerge -e system', we can get rid of the temporary tools.
		if [[ -d ${EPREFIX}/tmp/var/tmp ]] ; then
			rm -Rf "${EPREFIX}"/tmp || return 1
			mkdir -p "${EPREFIX}"/tmp || return 1
		fi

		hash -r  # tmp/* stuff is removed in stage3
	else
		# emerge -e system fail
		cat << EOF

Oh yeah, I thought I was almost there, and then this!  I did
  ${cmd}
and it failed at some point :(  Details might be found in the build log:
EOF
		for log in "${EPREFIX}"/var/tmp/portage/*/*/temp/build.log ; do
			[[ -e ${log} ]] || continue
			echo "  ${log}"
		done
		[[ -e ${log} ]] || echo "  (no build logs found?!?)"
		cat << EOF
I have no clue, really.  Please find friendly folks in #gentoo-prefix on
irc.gentoo.org, gentoo-alt@lists.gentoo.org mailing list, or file a bug
at bugs.gentoo.org under Gentoo/Alt, Prefix Support.
You know, I got the feeling you just started to like me, but I guess
that's all gone now.  I'll bother you no longer.
EOF
		exit 1
	fi

	if ! bash ${BASH_SOURCE[0]} "${EPREFIX}" startscript ; then
		# startscript fail?
		cat << EOF

Ok, let's be honest towards each other.  If
  $(type -P bash) ${BASH_SOURCE[0]} "${EPREFIX}" startscript
fails, then who cheated on who?  Either you use an obscure shell, or
your PATH isn't really sane afterall.  Despite, I can't really
congratulate you here, you basically made it to the end.
Please find friendly folks in #gentoo-prefix on irc.gentoo.org,
gentoo-alt@lists.gentoo.org mailing list, or file a bug at
bugs.gentoo.org under Gentoo/Alt, Prefix Support.
It's sad we have to leave each other this way.  Just an inch away...
EOF
		exit 1
	fi

	echo
	cat << EOF

Woah!  Everything just worked!  Now YOU should run
  ${EPREFIX}/startprefix
and enjoy!  Thanks for using me, it was a pleasure to work with you.
EOF
}

## End Functions

## some vars

# We do not want stray $TMP, $TMPDIR or $TEMP settings
unset TMP TMPDIR TEMP

# Try to guess the CHOST if not set.  We currently only support guessing
# on a very sloppy base.
if [[ -z ${CHOST} ]]; then
	if [[ x$(type -t uname) == "xfile" ]]; then
		case `uname -s` in
			Linux)
				plt="gnu"
				[[ -e /lib/ld-musl-*.so.1 ]] && plt="musl"
				sfx="unknown-linux-${plt}"
				case `uname -m` in
					ppc*)
						CHOST="`uname -m | sed -e 's/^ppc/powerpc/'`-${sfx}"
						;;
					powerpc*|aarch64*)
						CHOST="`uname -m`-${sfx}"
						;;
					*)
						CHOST="`uname -m`-${sfx/unknown/pc}"
						;;
				esac
				;;
			Darwin)
				rev="`uname -r | cut -d'.' -f 1`"
				if [[ ${rev} -ge 11 && ${rev} -le 19 ]] ; then
					# Lion and up are 64-bits default (and 64-bits CPUs)
					CHOST="x86_64-apple-darwin$rev"
				elif [[ ${rev} -ge 20 ]] ; then
					# uname -p returns arm, -m returns arm64 on this
					# release while on Darwin 9 -m returns something
					# like "PowerPC Machine", hence the distinction
					CHOST="`uname -m`-apple-darwin$rev"
				else
					CHOST="`uname -p`-apple-darwin$rev"
				fi
				;;
			SunOS)
				case `uname -p` in
					i386)
						CHOST="i386-pc-solaris`uname -r | sed 's|5|2|'`"
					;;
					sparc)
						CHOST="sparc-sun-solaris`uname -r | sed 's|5|2|'`"
					;;
				esac
				;;
			CYGWIN*)
				CHOST="`uname -m`-pc-cygwin"
				;;
			FreeBSD)
				case `uname -m` in
					amd64)
						CHOST="x86_64-pc-freebsd`uname -r | sed 's|-.*$||'`"
					;;
				esac
				;;
			OpenBSD)
				case `uname -m` in
					amd64)
						CHOST="x86_64-pc-openbsd`uname -r | sed 's|-.*$||'`"
					;;
				esac
				;;
			*)
				eerror "Nothing known about platform `uname -s`."
				eerror "Please set CHOST appropriately for your system"
				eerror "and rerun $0"
				exit 1
				;;
		esac
	fi
fi

# Now based on the CHOST set some required variables.  Doing it here
# allows for user set CHOST still to result in the appropriate variables
# being set.
case ${CHOST} in
	*-*-solaris*)
		if type -P gmake > /dev/null ; then
			MAKE=gmake
		else
			MAKE=make
		fi
	;;
	*)
		MAKE=make
	;;
esac

# handle GCC install path on recent Darwin
case ${CHOST} in
	powerpc-*darwin*)
		DARWIN_USE_GCC=1  # must use GCC, Clang is impossible
		;;
	*-darwin*)
		# normalise value of DARWIN_USE_GCC
		case ${DARWIN_USE_GCC} in
			yes|true|1)  DARWIN_USE_GCC=1  ;;
			no|false|0)  DARWIN_USE_GCC=0  ;;
			*)           DARWIN_USE_GCC=1  ;;   # default to GCC build
		esac
		;;
	*)
		unset DARWIN_USE_GCC
		;;
esac

# deal with a problem on OSX with Python's locales
case ${CHOST}:${LC_ALL}:${LANG} in
	*-darwin*:UTF-8:*|*-darwin*:*:UTF-8)
		eerror "Your LC_ALL and/or LANG is set to 'UTF-8'."
		eerror "This setting is known to cause trouble with Python.  Please run"
		case ${SHELL} in
			*/tcsh|*/csh)
				eerror "  setenv LC_ALL en_US.UTF-8"
				eerror "  setenv LANG en_US.UTF-8"
				eerror "and make it permanent by adding it to your ~/.${SHELL##*/}rc"
				exit 1
			;;
			*)
				eerror "  export LC_ALL=en_US.UTF-8"
				eerror "  export LANG=en_US.UTF-8"
				eerror "and make it permanent by adding it to your ~/.profile"
				exit 1
			;;
		esac
	;;
esac

# save original path, need this before interactive, #788334
ORIGINAL_PATH="${PATH}"

# Just guessing a prefix is kind of scary.  Hence, to make it a bit less
# scary, we force the user to give the prefix location here.  This also
# makes the script a bit less dangerous as it will die when just run to
# "see what happens".
if [[ -n $1 && -z $2 ]] ; then
	echo "usage: $0 [<prefix-path> <action>]"
	echo
	echo "Either you give no argument and I'll ask you interactively, or"
	echo "you need to give both the path offset for your Gentoo prefixed"
	echo "portage installation, and the action I should do there, e.g."
	echo "  $0 $HOME/prefix <action>"
	echo
	echo "See the source of this script for which actions exist."
	echo
	echo "$0: insufficient number of arguments" 1>&2
	exit 1
elif [[ -z $1 ]] ; then
	bootstrap_interactive
	exit 0
fi

ROOT="$1"
set_helper_vars

case $ROOT in
	chost.guess)
		# undocumented feature that sort of is our own config.guess, if
		# CHOST was unset, it now contains the guessed CHOST
		echo "$CHOST"
		exit 0
	;;
	/*) ;;
	*)
		echo "Your path offset needs to be absolute!" 1>&2
		exit 1
	;;
esac


einfo "Bootstrapping Gentoo prefixed portage installation using"
einfo "host:   ${CHOST}"
einfo "prefix: ${ROOT}"

TODO=${2}
if [[ ${TODO} != "noninteractive" && $(type -t bootstrap_${TODO}) != "function" ]];
then
	eerror "bootstrap target ${TODO} unknown"
	exit 1
fi

if [[ -n ${LD_LIBRARY_PATH} || -n ${DYLD_LIBRARY_PATH} ]] ; then
	eerror "EEEEEK!  You have LD_LIBRARY_PATH or DYLD_LIBRARY_PATH set"
	eerror "in your environment.  This is a guarantee for TROUBLE."
	eerror "Cowardly refusing to operate any further this way!"
	exit 1
fi

if [[ -n ${PKG_CONFIG_PATH} ]] ; then
	eerror "YUK!  You have PKG_CONFIG_PATH set in your environment."
	eerror "This is a guarantee for TROUBLE."
	eerror "Cowardly refusing to operate any further this way!"
	exit 1
fi

einfo "ready to bootstrap ${TODO}"
# bootstrap_interactive proceeds with guessed defaults when TODO=noninteractive
bootstrap_${TODO#non} || exit 1

# Local Variables:
# sh-indentation: 8
# sh-basic-offset: 8
# indent-tabs-mode: t
# End:
