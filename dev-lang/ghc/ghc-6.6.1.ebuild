# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/ghc/ghc-6.6.1.ebuild,v 1.21 2010/07/21 21:49:33 slyfox Exp $

# Brief explanation of the bootstrap logic:
#
# Previous ghc ebuilds have been split into two: ghc and ghc-bin,
# where ghc-bin was primarily used for bootstrapping purposes.
# From now on, these two ebuilds have been combined, with the
# binary USE flag used to determine whether or not the pre-built
# binary package should be emerged or whether ghc should be compiled
# from source.  If the latter, then the relevant ghc-bin for the
# arch in question will be used in the working directory to compile
# ghc from source.

# Note to users of hardened gcc-3.x:
#
# If you emerge ghc with hardened gcc it should work fine (because we
# turn off the hardened features that would otherwise break ghc).
# However, emerging ghc while using a vanilla gcc and then switching to
# hardened gcc (using gcc-config) will leave you with a broken ghc. To
# fix it you would need to either switch back to vanilla gcc or re-emerge
# ghc (or ghc-bin). Note that also if you are using hardened gcc-3.x and
# you switch to gcc-4.x that this will also break ghc and you'll need to
# re-emerge ghc (or ghc-bin). People using vanilla gcc can switch between
# gcc-3.x and 4.x with no problems.

inherit base bash-completion eutils flag-o-matic multilib toolchain-funcs ghc-package versionator prefix

DESCRIPTION="The Glasgow Haskell Compiler"
HOMEPAGE="http://www.haskell.org/ghc/"

# discover if this is a snapshot release
IS_SNAPSHOT="${PV%%*pre*}" # zero if snapshot
MY_PV="${PV/_pre/.}"
MY_P="${PN}-${MY_PV}"
EXTRA_SRC_URI="${MY_PV}"
[[ -z "${IS_SNAPSHOT}" ]] && EXTRA_SRC_URI="current/dist"

SRC_URI="!binary? ( http://haskell.org/ghc/dist/${EXTRA_SRC_URI}/${MY_P}-src.tar.bz2 )
		 alpha? ( mirror://gentoo/ghc-bin-${PV}-alpha.tbz2 )
		 amd64?	( mirror://gentoo/ghc-bin-${PV}-amd64.tbz2 )
		 ia64?	( mirror://gentoo/ghc-bin-${PV}-ia64.tbz2 )
		 ppc?	( mirror://gentoo/ghc-bin-${PV}-ppc.tbz2 )
		 sparc?	( mirror://gentoo/ghc-bin-${PV}-sparc.tbz2 )
		 x86?	( mirror://gentoo/ghc-bin-${PV}-x86.tbz2 )
		 sparc-solaris? ( http://haskell.org/ghc/dist/${PV}/ghc-${PV}-sparc-sun-solaris2.tar.bz2 )
		 x86-solaris? ( http://haskell.org/ghc/dist/${PV}/ghc-${PV}-i386-unknown-solaris2.tar.bz2 )
		 ppc-macos? ( http://haskell.org/ghc/dist/${PV}/ghc-${PV}-powerpc-apple-darwin.tar.bz2 )
		 x86-macos? ( http://haskell.org/ghc/dist/${PV}/ghc-${PV}-i386-apple-darwin.tar.bz2 )
		 "

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="binary doc ghcbootstrap"

LOC="/opt/ghc" # location for installation of binary version
S="${WORKDIR}/${MY_P}"

RDEPEND="
	!dev-lang/ghc-bin
	!kernel_Darwin? ( >=sys-devel/gcc-2.95.3 )
	kernel_linux? ( >=sys-devel/binutils-2.17 )
	kernel_SunOS? ( >=sys-devel/binutils-2.17 )
	kernel_SunOS? ( app-admin/chrpath )
	>=dev-lang/perl-5.6.1
	>=dev-libs/gmp-4.1
	=sys-libs/readline-5*"

DEPEND="${RDEPEND}
	ghcbootstrap? (	doc? (	~app-text/docbook-xml-dtd-4.2
							app-text/docbook-xsl-stylesheets
							>=dev-libs/libxslt-1.1.2
							>=dev-haskell/haddock-0.8 ) )"
# In the ghcbootstrap case we rely on the developer having
# >=ghc-5.04.3 on their $PATH already

PDEPEND=">=dev-haskell/cabal-1.1.6.2
		 >=dev-haskell/regex-base-0.72
		 >=dev-haskell/regex-posix-0.71
		 >=dev-haskell/regex-compat-0.71"

append-ghc-cflags() {
	local flag compile assemble link
	for flag in $*; do
		case ${flag} in
			compile)	compile="yes";;
			assemble)	assemble="yes";;
			link)		link="yes";;
			*)
				[[ ${compile}  ]] && GHC_CFLAGS="${GHC_CFLAGS} -optc${flag}"
				[[ ${assemble} ]] && GHC_CFLAGS="${GHC_CFLAGS} -opta${flag}"
				[[ ${link}     ]] && GHC_CFLAGS="${GHC_CFLAGS} -optl${flag}";;
		esac
	done
}

ghc_setup_cflags() {
	# We need to be very careful with the CFLAGS we ask ghc to pass through to
	# gcc. There are plenty of flags which will make gcc produce output that
	# breaks ghc in various ways. The main ones we want to pass through are
	# -mcpu / -march flags. These are important for arches like alpha & sparc.
	# We also use these CFLAGS for building the C parts of ghc, ie the rts.
	strip-flags
	strip-unsupported-flags
	filter-flags -fPIC

	GHC_CFLAGS=""
	for flag in ${CFLAGS}; do
		case ${flag} in

			# Ignore extra optimisation (ghc passes -O to gcc anyway)
			# -O2 and above break on too many systems
			-O*) ;;

			# Arch and ABI flags are what we're really after
			-m*) append-ghc-cflags compile assemble ${flag};;

			# Debugging flags don't help either. You can't debug Haskell code
			# at the C source level and the mangler discards the debug info.
			-g*) ;;

			# Ignore all other flags, including all -f* flags
		esac
	done

	# hardened-gcc needs to be disabled, because the mangler doesn't accept
	# its output.
	gcc-specs-pie && append-ghc-cflags compile link	-nopie
	gcc-specs-ssp && append-ghc-cflags compile		-fno-stack-protector

	# We also add -Wa,--noexecstack to get ghc to generate .o files with
	# non-exectable stack. This it a hack until ghc does it itself properly.
	[[ ${CHOST} == *-linux-gnu || ${CHOST} == *-solaris* ]] && \
		append-ghc-cflags assemble		"-Wa,--noexecstack"
	[[ ${CHOST} == *-darwin9 ]] && \
		append-ghc-cflags compile "-D__DARWIN_UNIX03=0"
}

pkg_setup() {
	if use ghcbootstrap; then
		ewarn "You requested ghc bootstrapping, this is usually only used"
		ewarn "by Gentoo developers to make binary .tbz2 packages for"
		ewarn "use with the ghc ebuild's USE=\"binary\" feature."
		use binary && \
			die "USE=\"ghcbootstrap binary\" is not a valid combination."
		[[ -z $(type -P ghc) ]] && \
			die "Could not find a ghc to bootstrap with."
	elif use ppc64; then
		eerror "No binary .tbz2 package available yet for these arches:"
		eerror "  ppc64"
		eerror "Please try emerging with USE=ghcbootstrap and report build"
		eerror "sucess or failure to the haskell team (haskell@gentoo.org)"
		die "No binary available for this arch yet, USE=ghcbootstrap"
	fi

	set_config
}

set_config() {
	# make this a separate function and call it several times as portage doesn't
	# remember the variables properly between the fuctions.
	use binary && GHC_PREFIX="/opt/ghc" || GHC_PREFIX="/usr"

	use binary && use ppc-macos && die "Cannot USE=binary on ppc-macos"
	use binary && use x86-macos && die "Cannot USE=binary on x86-macos"
	use binary && use sparc-solaris && die "Cannot USE=binary on sparc-solaris"
	use binary && use x86-solaris && die "Cannot USE=binary on x86-solaris"
}

src_unpack() {
	# Create the ${S} dir if we're using the binary version
	use binary && mkdir "${S}"

	[[ ${CHOST} != *-linux-gnu ]] && ONLYA=${MY_P}-src.tar.bz2
	base_src_unpack
	source "${FILESDIR}/ghc-apply-gmp-hack" "$(get_libdir)"

	ghc_setup_cflags

	if use binary; then

		# Move unpacked files to the expected place
		mv "${WORKDIR}/usr" "${S}"

		# Relocate from /usr to /opt/ghc
		sed -i -e "s|/usr|${LOC}|g" \
			"${S}/usr/bin/ghc-${PV}" \
			"${S}/usr/bin/ghci-${PV}" \
			"${S}/usr/bin/ghc-pkg-${PV}" \
			"${S}/usr/bin/hsc2hs" \
			"${S}"/usr/lib*/${P}/package.conf \
			|| die "Relocating ghc from /usr to /opt/ghc failed"

		sed -i -e "s|/usr/lib[^/]|${LOC}/$(get_libdir)|" \
			"${S}/usr/bin/ghcprof"

	else

		# Modify the ghc driver script to use GHC_CFLAGS
		echo "SCRIPT_SUBST_VARS += GHC_CFLAGS" >> "${S}/driver/ghc/Makefile"
		echo "GHC_CFLAGS = ${GHC_CFLAGS}"      >> "${S}/driver/ghc/Makefile"
		sed -i -e 's|$TOPDIROPT|$TOPDIROPT $GHC_CFLAGS|' "${S}/driver/ghc/ghc.sh"

		if ! use ghcbootstrap; then
			if [[ ${CHOST} == *-linux-gnu ]] ; then
				# Relocate from /usr to ${WORKDIR}/usr
				sed -i -e "s|/usr|${WORKDIR}/usr|g" \
					"${WORKDIR}/usr/bin/ghc-${PV}" \
					"${WORKDIR}/usr/bin/ghci-${PV}" \
					"${WORKDIR}/usr/bin/ghc-pkg-${PV}" \
					"${WORKDIR}/usr/bin/hsc2hs" \
					"${WORKDIR}/usr/$(get_libdir)/${P}/package.conf" \
					|| die "Relocating ghc from /usr to workdir failed"
			else
				mkdir "${WORKDIR}"/ghc-bin-installer || die
				cd "${WORKDIR}"/ghc-bin-installer || die
				use sparc-solaris && unpack ghc-${PV}-sparc-sun-solaris2.tar.bz2
				use x86-solaris && unpack ghc-${PV}-i386-unknown-solaris2.tar.bz2
				use ppc-macos && unpack ghc-${PV}-powerpc-apple-darwin.tar.bz2
				use x86-macos && unpack ghc-${PV}-i386-apple-darwin.tar.bz2

				# it is autoconf, but we really don't want to give it too
				# much arguments, in fact we do the make in-place anyway
				cd ${P}
				./configure || die
				make in-place || die
				# fix the binaries so they run, on Solaris we need an rpath
				# which has our prefix libdirs, on Darwin we need to
				# replace the frameworks with our libs from the prefix
				if [[ ${CHOST} == *-solaris* ]] ; then
					chrpath -r \
						"${EPREFIX}/$(get_libdir):${EPREFIX}/usr/$(get_libdir)" \
						lib/*-*-solaris2/ghc-${PV} || die
				elif [[ ${CHOST} == *-darwin* ]] ; then
					local readline_framework
					if [[ ${CHOST} == powerpc-*-darwin* ]]; then
						readline_framework=GNUreadline.framework/GNUreadline
					else
						readline_framework=GNUreadline.framework/Versions/A/GNUreadline
					fi
					for binary in lib/*-apple-darwin/ghc-{${PV},pkg.bin}; do
						install_name_tool -change \
							${readline_framework} \
							"${EPREFIX}"/lib/libreadline.dylib \
							${binary} || die
						install_name_tool -change \
							GMP.framework/Versions/A/GMP \
							"${EPREFIX}"/usr/lib/libgmp.dylib \
							${binary} || die
					done
					# we don't do frameworks!
					sed -i \
						-e 's/\(frameworks = \)\["GMP"\]/\1[]/g' \
						-e 's/\(extraLibraries = \)\["m"\]/\1["m","gmp"]/g' \
						lib/*-apple-darwin/package.conf || die
				fi

				# Now we need to create some symlinks so this binary looks like
				# what the gentoo binaries have...
				mkdir -p "${WORKDIR}"/usr || die
				cd "${WORKDIR}"/usr || die
				ln -s "${WORKDIR}"/ghc-bin-installer/${P}/bin/* bin || die
			fi
		fi

		# If we're using the testsuite then move it to into the build tree
		#	use test && mv "${WORKDIR}/testsuite" "${S}/"

		# Don't strip binaries on install. See QA warnings in bug #140369.
		sed -i -e 's/SRC_INSTALL_BIN_OPTS	+= -s//' "${S}/mk/config.mk.in"

		# Temporary patches that needs testing before being pushed upstream:
		cd "${S}"
		# Fix sparc split-objs linking problem
		epatch "${FILESDIR}/ghc-6.5-norelax.patch"

		# Fix problems with locales other than English
		epatch "${FILESDIR}"/${P}-detect-gcc-english.patch

		# Make configure find docbook-xsl-stylesheets in prefix
		epatch "${FILESDIR}"/${P}-prefix.patch
		eprefixify configure.ac

		eautoreconf
	fi
}

src_compile() {
	if ! use binary; then

		# initialize build.mk
		echo '# Gentoo changes' > mk/build.mk

		# We also need to use the GHC_CFLAGS flags when building ghc itself
		echo "SRC_HC_OPTS+=${GHC_CFLAGS}" >> mk/build.mk
		[[ ${CHOST} == *-linux-gnu || ${CHOST} == *-solaris* ]] && \
			echo "SRC_CC_OPTS+=${CFLAGS} -Wa,--noexecstack" >> mk/build.mk

		# If you need to do a quick build then enable this bit and add debug to IUSE
		#if use debug; then
		#	echo "SRC_HC_OPTS     = -H32m -O -fasm" >> mk/build.mk
		#	echo "GhcLibHcOpts    =" >> mk/build.mk
		#	echo "GhcLibWays      =" >> mk/build.mk
		#	echo "SplitObjs       = NO" >> mk/build.mk
		#fi

		# We can't depend on haddock except when bootstrapping when we
		# must build docs and include them into the binary .tbz2 package
		if use ghcbootstrap && use doc; then
			echo XMLDocWays="html" >> mk/build.mk
		else
			echo XMLDocWays="" >> mk/build.mk
			# needed to prevent haddock from being called
			echo NO_HADDOCK_DOCS=YES >> mk/build.mk
		fi

		# circumvent a very strange bug that seems related with ghc producing too much
		# output while being filtered through tee (e.g. due to portage logging)
		# reported as bug #111183
		echo "SRC_HC_OPTS+=-fno-warn-deprecations" >> mk/build.mk

		# GHC build system knows to build unregisterised on alpha,
		# but we have to tell it to build unregisterised on some arches
		if use alpha || use ppc64 || use sparc; then
			echo "GhcUnregisterised=YES" >> mk/build.mk
			echo "GhcWithInterpreter=NO" >> mk/build.mk
		fi
		if use alpha || use ppc64 || use sparc; then
			echo "GhcWithNativeCodeGen=NO" >> mk/build.mk
			echo "SplitObjs=NO" >> mk/build.mk
			echo "GhcRTSWays := debug" >> mk/build.mk
			echo "GhcNotThreaded=YES" >> mk/build.mk
		fi

		# GHC <6.8 doesn't support GCC >=4.2, split objects fails.
		if version_is_at_least "4.2" "$(gcc-version)"; then
			echo "SplitObjs=NO" >> mk/build.mk
		fi

		# Get ghc from the unpacked binary .tbz2
		# except when bootstrapping we just pick ghc up off the path
		use ghcbootstrap || \
			export PATH="${WORKDIR}/usr/bin:${PATH}"

		econf || die "econf failed"

		# LC_ALL needs to workaround ghc's ParseCmm failure on some (es) locales
		# bug #202212 / http://hackage.haskell.org/trac/ghc/ticket/4207
		LC_ALL=C emake all datadir="${EPREFIX}/usr/share/doc/${P}" || die "make failed"
		# the explicit datadir is required to make the haddock entries
		# in the package.conf file point to the right place ...

	fi # ! use binary
}

src_install() {
	if use binary; then
		mkdir "${ED}/opt"
		mv "${S}/usr" "${ED}/opt/ghc"

		# Remove the docs if not requested
		if ! use doc; then
			rm -rf "${ED}/opt/ghc/share/doc/${P}/html" \
				|| die "could not remove docs (P vs PF revision mismatch?)"
		fi

		# TODO: this will not be necessary after version 6.6.1 since the .tbz2
		# packages will have been regenerated with package.conf.shipped files.
		cp -p "${ED}/${GHC_PREFIX}/$(get_libdir)/${P}/package.conf"{,.shipped} \
			|| die "failed to copy package.conf"

		doenvd "${FILESDIR}/10ghc"
	else
		local insttarget="install"

		# We only built docs if we were bootstrapping, otherwise
		# we copy them out of the unpacked binary .tbz2
		if use doc; then
			if use ghcbootstrap; then
				insttarget="${insttarget} install-docs"
			else
				dohtml -A haddock -r "${WORKDIR}/usr/share/doc/${P}/html/"*
			fi
		fi

		# the libdir0 setting is needed for amd64, and does not
		# harm for other arches
		#TODO: are any of these overrides still required? isn't econf enough?
		emake -j1 ${insttarget} \
			prefix="${ED}/usr" \
			datadir="${ED}/usr/share/doc/${P}" \
			infodir="${ED}/usr/share/info" \
			mandir="${ED}/usr/share/man" \
			libdir0="${ED}/usr/$(get_libdir)" \
			|| die "make ${insttarget} failed"

		cd "${S}"
		dodoc README ANNOUNCE VERSION

		# make ghc-updater prefix-friendly
		cd "${T}"
		cp "${FILESDIR}/ghc-updater" .
		epatch "${FILESDIR}"/ghc-updater-prefix.patch
		eprefixify ghc-updater
		dosbin ghc-updater

		dobashcompletion "${FILESDIR}/ghc-bash-completion"

		cp -p "${ED}/${GHC_PREFIX}/$(get_libdir)/${P}/package.conf"{,.shipped} \
			|| die "failed to copy package.conf"
	fi
}

pkg_postinst() {
	ghc-reregister

	if use binary; then
		elog "The envirenment has been set to use the binary distribution of"
		elog "GHC. In order to activate it please run:"
		elog "   env-update && source /etc/profile"
		elog "Otherwise this setting will become active the next time you login"
	fi

	ewarn "IMPORTANT:"
	ewarn "If you have upgraded from another version of ghc or"
	ewarn "if you have switched between binary and source versions"
	ewarn "of ghc, please run:"
	if use binary; then
		ewarn "      /opt/ghc/sbin/ghc-updater"
	else
		ewarn "      /usr/sbin/ghc-updater"
	fi
	ewarn "to re-merge all ghc-based Haskell libraries."

	bash-completion_pkg_postinst
}

pkg_prerm() {
	# Overwrite the (potentially) modified package.conf with a copy of the
	# original one, so that it will be removed during uninstall.

	set_config # load GHC_PREFIX

	PKG="${EROOT}/${GHC_PREFIX}/$(get_libdir)/${P}/package.conf"

	cp -p "${PKG}"{.shipped,}

	[[ -f ${PKG}.old ]] && rm "${PKG}.old"
}
