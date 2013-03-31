# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id: portage-2.2.01.16270.ebuild 58665 2010-09-05 19:54:38Z grobian $

# Require EAPI 2 since we now require at least python-2.6 (for python 3
# syntax support) which also requires EAPI 2.
EAPI=3
inherit eutils multilib python

DESCRIPTION="Prefix branch of the Portage Package Manager, used in Gentoo Prefix"
HOMEPAGE="http://www.gentoo.org/proj/en/gentoo-alt/prefix/"
LICENSE="GPL-2"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
SLOT="0"
IUSE="build doc epydoc +ipc linguas_pl pypy1_9 python2 python3 selinux xattr prefix-chaining"

RESTRICT="test"

# Import of the io module in python-2.6 raises ImportError for the
# thread module if threading is disabled.
python_dep_ssl="python3? ( =dev-lang/python-3*[ssl] )
	!pypy1_9? ( !python2? ( !python3? (
		|| ( >=dev-lang/python-2.7[ssl] dev-lang/python:2.6[threads,ssl] )
	) ) )
	pypy1_9? ( !python2? ( !python3? ( dev-python/pypy:1.9[bzip2,ssl] ) ) )
	python2? ( !python3? ( || ( dev-lang/python:2.7[ssl] dev-lang/python:2.6[ssl,threads] ) ) )"
python_dep="${python_dep_ssl//\[ssl\]}"
python_dep="${python_dep//,ssl}"
python_dep="${python_dep//ssl,}"

# The pysqlite blocker is for bug #282760.
DEPEND="${python_dep}
	>=sys-apps/sed-4.0.5 sys-devel/patch
	doc? ( app-text/xmlto ~app-text/docbook-xml-dtd-4.4 )
	epydoc? ( >=dev-python/epydoc-2.0 !<=dev-python/pysqlite-2.4.1 )"
# Require sandbox-2.2 for bug #288863.
# For xattr, we can spawn getfattr and setfattr from sys-apps/attr, but that's
# quite slow, so it's not considered in the dependencies as an alternative to
# to python-3.3 / pyxattr. Also, xattr support is only tested with Linux, so
# for now, don't pull in xattr deps for other kernels.
# For whirlpool hash, require python[ssl] or python-mhash (bug #425046).
# bash-4.1 necessary for redirect_alloc_fd, which fails on non-Linux if bash
# doesn't have a builtin for finding a random filedescriptor
RDEPEND="${python_dep} || ( ${python_dep_ssl} dev-python/python-mhash )
	!build? ( >=sys-apps/sed-4.0.5
		>=app-shells/bash-4.1
		>=app-admin/eselect-1.2 )
	elibc_FreeBSD? ( !prefix? ( sys-freebsd/freebsd-bin ) )
	elibc_glibc? ( !prefix? ( >=sys-apps/sandbox-2.2 ) )
	elibc_uclibc? ( !prefix? ( >=sys-apps/sandbox-2.2 ) )
	kernel_linux? ( >=app-misc/pax-utils-0.1.17 )
	kernel_SunOS? ( >=app-misc/pax-utils-0.1.17 )
	kernel_FreeBSD? ( >=app-misc/pax-utils-0.1.17 )
	kernel_Darwin? ( >=app-misc/pax-utils-0.1.18 )
	kernel_HPUX? ( !hppa-hpux? ( >=app-misc/pax-utils-0.1.19 ) )
	kernel_AIX? ( >=sys-apps/aix-miscutils-0.1.1634 )
	xattr? ( kernel_linux? ( || ( >=dev-lang/python-3.3_pre20110902 dev-python/pyxattr ) ) )
	selinux? ( || ( >=sys-libs/libselinux-2.0.94[python] <sys-libs/libselinux-2.0.94 ) )
	!<app-shells/bash-3.2_p17
	!prefix? ( !<app-admin/logrotate-3.8.0 )"
PDEPEND="
	!build? (
		>=net-misc/rsync-2.6.4
		userland_GNU? ( >=sys-apps/coreutils-6.4 )
	)"
# coreutils-6.4 rdep is for date format in emerge-webrsync #164532
# NOTE: FEATURES=install-sources requires debugedit and rsync

SRC_ARCHIVES="http://dev.gentoo.org/~zmedico/portage/archives http://dev.gentoo.org/~grobian/distfiles"

prefix_src_archives() {
	local x y
	for x in ${@}; do
		for y in ${SRC_ARCHIVES}; do
			echo ${y}/${x}
		done
	done
}

PV_PL="2.1.2"
PATCHVER_PL=""
TARBALL_PV="${PV}"
SRC_URI="$(prefix_src_archives prefix-${PN}-${TARBALL_PV}.tar.bz2)
	linguas_pl? ( $(prefix_src_archives ${PN}-man-pl-${PV_PL}.tar.bz2) )"

PATCHVER=
[[ $TARBALL_PV = $PV ]] || PATCHVER=$PV
if [ -n "${PATCHVER}" ]; then
	SRC_URI="${SRC_URI} mirror://gentoo/${PN}-${PATCHVER}.patch.bz2
	$(prefix_src_archives ${PN}-${PATCHVER}.patch.bz2)"
fi

S="${WORKDIR}"/prefix-${PN}-${TARBALL_PV}
S_PL="${WORKDIR}"/${PN}-${PV_PL}

compatible_python_is_selected() {
	[[ $("${EPREFIX}/usr/bin/python" -c 'import sys ; sys.stdout.write(sys.hexversion >= 0x2060000 and "good" or "bad")') = good ]]
}

current_python_has_xattr() {
	[[ $("${EPREFIX}/usr/bin/python" -c 'import sys ; sys.stdout.write(sys.hexversion >= 0x3030000 and "yes" or "no")') = yes ]] || \
	"${EPREFIX}/usr/bin/python" -c 'import xattr' 2>/dev/null
}

pkg_setup() {
	if use python2 && use python3 ; then
		ewarn "Both python2 and python3 USE flags are enabled, but only one"
		ewarn "can be in the shebangs. Using python3."
	fi
	if use pypy1_9 && use python3 ; then
		ewarn "Both pypy1_9 and python3 USE flags are enabled, but only one"
		ewarn "can be in the shebangs. Using python3."
	fi
	if use pypy1_9 && use python2 ; then
		ewarn "Both pypy1_9 and python2 USE flags are enabled, but only one"
		ewarn "can be in the shebangs. Using python2"
	fi
	if ! use pypy1_9 && ! use python2 && ! use python3 && \
		! compatible_python_is_selected ; then
		ewarn "Attempting to select a compatible default python interpreter"
		local x success=0
		for x in "${EPREFIX}"/usr/bin/python2.* ; do
			x=${x#${EPREFIX}/usr/bin/python2.}
			if [[ $x -ge 6 ]] 2>/dev/null ; then
				eselect python set python2.$x
				if compatible_python_is_selected ; then
					elog "Default python interpreter is now set to python-2.$x"
					success=1
					break
				fi
			fi
		done
		if [ $success != 1 ] ; then
			eerror "Unable to select a compatible default python interpreter!"
			die "This version of portage requires at least python-2.6 to be selected as the default python interpreter (see \`eselect python --help\`)."
		fi
	fi

	if use python3; then
		python_set_active_version 3
	elif use python2; then
		python_set_active_version 2
	elif use pypy1_9; then
		python_set_active_version 2.7-pypy-1.9
	fi
}

src_prepare() {
	if [ -n "${PATCHVER}" ] ; then
		if [[ -L $S/bin/ebuild-helpers/portageq ]] ; then
			rm "$S/bin/ebuild-helpers/portageq" \
				|| die "failed to remove portageq helper symlink"
		fi
		epatch "${WORKDIR}/${PN}-${PATCHVER}.patch"
	fi

	use prefix-chaining && epatch "${FILESDIR}"/${PN}-2.2.00.15801-prefix-chaining.patch
	epatch "${FILESDIR}"/${PN}-2.2.01.20239-ebuildshell.patch

	if ! use ipc ; then
		einfo "Disabling ipc..."
		sed -e "s:_enable_ipc_daemon = True:_enable_ipc_daemon = False:" \
			-i pym/_emerge/AbstractEbuildProcess.py || \
			die "failed to patch AbstractEbuildProcess.py"
	fi

	if use xattr && use kernel_linux ; then
		einfo "Adding FEATURES=xattr to make.globals ..."
		echo -e '\nFEATURES="${FEATURES} xattr"' >> cnf/make.globals \
			|| die "failed to append to make.globals"
	fi

	if use python3; then
		einfo "Converting shebangs for python3..."
		python_convert_shebangs -r 3 .
	elif use python2; then
		einfo "Converting shebangs for python2..."
		python_convert_shebangs -r 2 .
	elif use pypy1_9; then
		einfo "Converting shebangs for pypy-c1.9..."
		python_convert_shebangs -r 2.7-pypy-1.9 .
	fi

	# "native" Prefix still uses configure
	if use !prefix && [[ -n ${EPREFIX} ]] ; then
		einfo "Setting portage.const.EPREFIX ..."
		sed -e "s|^\(SANDBOX_BINARY[[:space:]]*=[[:space:]]*\"\)\(/usr/bin/sandbox\"\)|\\1${EPREFIX}\\2|" \
			-e "s|^\(FAKEROOT_BINARY[[:space:]]*=[[:space:]]*\"\)\(/usr/bin/fakeroot\"\)|\\1${EPREFIX}\\2|" \
			-e "s|^\(BASH_BINARY[[:space:]]*=[[:space:]]*\"\)\(/bin/bash\"\)|\\1${EPREFIX}\\2|" \
			-e "s|^\(MOVE_BINARY[[:space:]]*=[[:space:]]*\"\)\(/bin/mv\"\)|\\1${EPREFIX}\\2|" \
			-e "s|^\(PRELINK_BINARY[[:space:]]*=[[:space:]]*\"\)\(/usr/sbin/prelink\"\)|\\1${EPREFIX}\\2|" \
			-e "s|^\(EPREFIX[[:space:]]*=[[:space:]]*\"\).*|\\1${EPREFIX}\"|" \
			-i pym/portage/const.py || \
			die "Failed to patch portage.const.EPREFIX"

		einfo "Prefixing shebangs ..."
		find . -type f -print0 | \
		while read -r -d $'\0' ; do
			local shebang=$(head -n1 "$REPLY")
			if [[ ${shebang} == "#!"* && ! ${shebang} == "#!${EPREFIX}/"* ]] ; then
				sed -i -e "1s:.*:#!${EPREFIX}${shebang:2}:" "$REPLY" || \
					die "sed failed"
			fi
		done

		einfo "Adjusting make.globals ..."
		sed -e 's|^SYNC=.*|SYNC="rsync://rsync.prefix.freens.org/gentoo-portage-prefix"|' \
			-e "s|^\(PORTDIR=\)\(/usr/portage\)|\\1\"${EPREFIX}\\2\"|" \
			-e "s|^\(PORTAGE_TMPDIR=\)\(/var/tmp\)|\\1\"${EPREFIX}\\2\"|" \
			-i cnf/make.globals || die "sed failed"

		einfo "Adding FEATURES=force-prefix to make.globals ..."
		echo -e '\nFEATURES="${FEATURES} force-prefix"' >> cnf/make.globals \
			|| die "failed to append to make.globals"
	fi

	if use !prefix ; then
	echo -e '\nFEATURES="${FEATURES} preserve-libs"' >> cnf/make.globals \
		|| die "failed to append to make.globals"

	cd "${S}/cnf" || die
	if [ -f "make.conf.${ARCH}".diff ]; then
		patch make.conf "make.conf.${ARCH}".diff || \
			die "Failed to patch make.conf.example"
	else
		eerror ""
		eerror "Portage does not have an arch-specific configuration for this arch."
		eerror "Please notify the arch maintainer about this issue. Using generic."
		eerror ""
	fi
	fi
}

src_configure() {
	if use prefix ; then
		local extrapath="/usr/bin:/bin"
		# ok, we can't rely on PORTAGE_ROOT_USER being there yet, as people
		# tend not to update that often, as long as we are a separate ebuild
		# we can assume when unset, it's time for some older trick
		if [[ -z ${PORTAGE_ROOT_USER} ]] ; then
			PORTAGE_ROOT_USER=$(python -c 'from portage.const import rootuser; print rootuser')
		fi
		# lazy check, but works for now
		if [[ ${PORTAGE_ROOT_USER} == "root" ]] ; then
			# we need this for e.g. mtree on FreeBSD (and Darwin) which is in
			# /usr/sbin
			extrapath="/usr/sbin:/usr/bin:/sbin:/bin"
		fi

		econf \
			--with-portage-user="${PORTAGE_USER:-portage}" \
			--with-portage-group="${PORTAGE_GROUP:-portage}" \
			--with-root-user="${PORTAGE_ROOT_USER}" \
			--with-offset-prefix="${EPREFIX}" \
			--with-extra-path="${extrapath}" \
			|| die "econf failed"
	else
		default
	fi
}

src_compile() {
	if use prefix ; then
		emake || die "emake failed"
	fi

	if use doc; then
		emake docbook || die
	fi

	if use epydoc; then
		einfo "Generating api docs"
		emake epydoc || die
	fi
}

src_test() {
	# make files executable, in case they were created by patch
	find bin -type f | xargs chmod +x
	emake test || die
}

src_install() {
	local libdir=$(get_libdir)
	local portage_base="/usr/${libdir}/portage"

	emake DESTDIR="${D}" install || die "make install failed."
	dodir /usr/lib/portage/bin

	if use userland_GNU; then
		rm "${ED}"${portage_base}/bin/ebuild-helpers/bsd/sed || die "Failed to remove sed wrapper"
	fi

	exeinto ${portage_base}/pym/portage/tests
	doexe  "${S}"/pym/portage/tests/runTests

	use doc && dohtml -r "${S}"/doc/*
	use epydoc && dohtml -r "${WORKDIR}"/api
	dodir /etc/portage
	keepdir /etc/portage

	# Use dodoc for compression, since the Makefile doesn't do that.
	dodoc "${S}"/{ChangeLog,NEWS,RELEASE-NOTES} || die

	if use linguas_pl; then
		doman -i18n=pl "${S_PL}"/man/pl/*.[0-9] || die
		doman -i18n=pl_PL.UTF-8 "${S_PL}"/man/pl_PL.UTF-8/*.[0-9] || die
	fi

	# Set PYTHONPATH for portage API consumers. This way we don't have
	# to rely on patched python having the correct path, since it has
	# been known to incorrectly add /usr/libx32/portage/pym to sys.path.
	echo "PYTHONPATH=\"${EPREFIX}/usr/lib/portage/pym\"" > \
		"${T}/05portage" || die
	doenvd "${T}/05portage" || die
}

pkg_preinst() {
	if [[ $ROOT == / ]] ; then
		# Run some minimal tests as a sanity check.
		local test_runner=$(find "$ED" -name runTests)
		if [[ -n $test_runner && -x $test_runner ]] ; then
			einfo "Running preinst sanity tests..."
			"$test_runner" || die "preinst sanity tests failed"
		fi
	fi

	if use xattr && ! current_python_has_xattr ; then
		ewarn "For optimal performance in xattr handling, install"
		ewarn "dev-python/pyxattr, or install >=dev-lang/python-3.3 and"
		ewarn "enable USE=python3 for $CATEGORY/$PN."
	fi

	if ! use build && ! has_version dev-python/pycrypto && \
		! has_version '>=dev-lang/python-2.6[ssl]' ; then
		ewarn "If you are an ebuild developer and you plan to commit ebuilds"
		ewarn "with this system then please install dev-python/pycrypto or"
		ewarn "enable the ssl USE flag for >=dev-lang/python-2.6 in order"
		ewarn "to enable RMD160 hash support."
		ewarn "See bug #198398 for more information."
	fi

	has_version "<=${CATEGORY}/${PN}-2.2.00.13346"
	EAPIPREFIX_UPGRADE=$?
}

pkg_postinst() {
	# Compile all source files recursively. Any orphans
	# will be identified and removed in postrm.
	python_mod_optimize /usr/lib/portage/pym

	pushd "${EROOT}var/db/pkg" > /dev/null
	local didwork=
	[[ ! -e "${EROOT}"var/lib/portage/preserved_libs_registry ]] && for cpv in */*/NEEDED ; do
		if [[ ${CHOST} == *-darwin* && ! -f ${cpv}.MACHO.3 ]] ; then
			while read line; do
				scanmacho -BF "%a;%F;%S;%n" ${line% *} >> "${cpv}".MACHO.3
			done < "${cpv}"
			[[ -z ${didwork} ]] \
				&& didwork=yes \
				|| didwork=already
		elif [[ ${CHOST} != *-darwin* && ${CHOST} != *-interix* && ! -f ${cpv}.ELF.2 ]] ; then
			while read line; do
				filename=${line% *}
				needed=${line#* }
				newline=$(scanelf -BF "%a;%F;%S;$needed;%r" $filename)
				echo "${newline:3}" >> "${cpv}".ELF.2
			done < "${cpv}"
			[[ -z ${didwork} ]] \
				&& didwork=yes \
				|| didwork=already
		fi
		[[ ${didwork} == yes ]] && \
			einfo "converting NEEDED files to new syntax, please wait"
	done
	popd > /dev/null

	if [[ ${EAPIPREFIX_UPGRADE} == 0 ]] ; then
		local eapi
		einfo 'removing EAPI="prefix" legacy from your vdb, please wait'
		pushd "${EROOT}var/db/pkg" > /dev/null
		for cpv in */* ; do
			[[ ${cpv##*/} == "-MERGING-"* ]] && continue
			# remove "prefix" from EAPI file
			eapi=$(<"${cpv}"/EAPI)
			eapi=${eapi/prefix/}
			eapi=${eapi# }
			eapi=${eapi:-0}
			echo ${eapi} > "${cpv}"/EAPI
			# remove "prefix" from EAPI in stored environment
			bzcat "${cpv}"/environment.bz2 \
				| sed -e "s/EAPI=\([\"']\)prefix [0-9][\"']/EAPI=\1${eapi}\1/" \
				| bzip2 -9 > "${cpv}"/environment2.bz2 \
				&& mv -f "${cpv}"/environment{2,}.bz2
			# remove "prefix" from the stored ebuild
			sed -i -e "s/^EAPI=.*$/EAPI=${eapi}/" "${cpv}/${cpv##*/}.ebuild"
		done
		popd > /dev/null
	fi
}

pkg_postrm() {
	python_mod_cleanup /usr/lib/portage/pym
}
