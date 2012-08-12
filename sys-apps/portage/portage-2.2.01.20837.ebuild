# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id: portage-2.2.01.16270.ebuild 58665 2010-09-05 19:54:38Z grobian $

# Require EAPI 2 since we now require at least python-2.6 (for python 3
# syntax support) which also requires EAPI 2.
EAPI=3
inherit eutils multilib python

RESTRICT="test"

DESCRIPTION="Prefix branch of the Portage Package Manager, used in Gentoo Prefix"
HOMEPAGE="http://www.gentoo.org/proj/en/gentoo-alt/prefix/"
LICENSE="GPL-2"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
SLOT="0"
IUSE="build doc epydoc ipc linguas_pl selinux xattr prefix-chaining"

# Import of the io module in python-2.6 raises ImportError for the
# thread module if threading is disabled.
python_dep_ssl="python3? ( =dev-lang/python-3*[ssl] )
	!pypy1_9? ( !python2? ( !python3? (
		|| ( >=dev-lang/python-2.7[ssl] dev-lang/python:2.6[threads,ssl] )
	) ) )
	pypy1_9? ( !python2? ( !python3? ( dev-python/pypy:1.9[bzip2,ssl] ) ) )
	python2? ( !python3? ( || ( dev-lang/python:2.7[ssl] dev-lang/python:2.6[ssl,threads] ) ) )"
python_dep_ssl=">=dev-lang/python-2.7[ssl] <dev-lang/python-3.0" # prefix override
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
RDEPEND="${python_dep} || ( ${python_dep_ssl} dev-python/python-mhash )
	!build? ( >=sys-apps/sed-4.0.5
		>=app-shells/bash-3.2_p17
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

#PATCHVER=$PV  # in prefix we don't do this
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
	use prefix && return

	# Bug #359731 - Die early if get_libdir fails.
	[[ -z $(get_libdir) ]] && \
		die "get_libdir returned an empty string"

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
		for x in /usr/bin/python2.* ; do
			x=${x#/usr/bin/python2.}
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

	if ! use ipc ; then
		einfo "Disabling ipc..."
		sed -e "s:_enable_ipc_daemon = True:_enable_ipc_daemon = False:" \
			-i pym/_emerge/AbstractEbuildProcess.py || \
			die "failed to patch AbstractEbuildProcess.py"
	fi

	epatch "${FILESDIR}"/${PN}-2.2.01.20239-ebuildshell.patch
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
		# even though above options would be correct, just keep it clean for
		# non-Prefix installs, relying on the autoconf defaults
		econf || die "econf failed"
	fi
}

src_compile() {
	emake || die "emake failed"

	if use doc; then
		cd "${S}"/doc
		touch fragment/date
		emake xhtml xhtml-nochunks || die "failed to make docs"
	fi

	if use epydoc; then
		einfo "Generating api docs"
		mkdir "${WORKDIR}"/api
		local my_modules epydoc_opts=""
		# A name collision between the portage.dbapi class and the
		# module with the same name triggers an epydoc crash unless
		# portage.dbapi is excluded from introspection.
		ROOT=/ has_version '>=dev-python/epydoc-3_pre0' && \
			epydoc_opts='--exclude-introspect portage\.dbapi'
		my_modules="$(find "${S}/pym" -name "*.py" \
			| sed -e 's:/__init__.py$::' -e 's:\.py$::' -e "s:^${S}/pym/::" \
			 -e 's:/:.:g' | sort)" || die "error listing modules"
		PYTHONPATH="${S}/pym:${PYTHONPATH}" epydoc -o "${WORKDIR}"/api \
			-qqqqq --no-frames --show-imports $epydoc_opts \
			--name "${PN}" --url "${HOMEPAGE}" \
			${my_modules} || die "epydoc failed"
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
		rm "${ED}"${portage_base}/bin/ebuild-helpers/sed || die "Failed to remove sed wrapper"
	fi

	# This allows config file updates that are applied for package
	# moves to take effect immediately.
	echo 'CONFIG_PROTECT_MASK="/etc/portage"' > "$T"/50portage \
		|| die "failed to create 50portage"
	doenvd "$T"/50portage || die "doenvd 50portage failed"
	rm "$T"/50portage

	# Symlinks to directories cause up/downgrade issues and the use of these
	# modules outside of portage is probably negligible.
	for x in "${ED}${portage_base}/pym/"{cache,elog_modules} ; do
		[ ! -L "${x}" ] && continue
		die "symlink to directory will cause upgrade/downgrade issues: '${x}'"
	done

	exeinto ${portage_base}/pym/portage/tests
	doexe  "${S}"/pym/portage/tests/runTests

	if use linguas_pl; then
		doman -i18n=pl "${S_PL}"/man/pl/*.[0-9] || die
		doman -i18n=pl_PL.UTF-8 "${S_PL}"/man/pl_PL.UTF-8/*.[0-9] || die
	fi

	dodoc "${S}"/{ChangeLog,NEWS,RELEASE-NOTES}
	use doc && dohtml -r "${S}"/doc/*
	use epydoc && dohtml -r "${WORKDIR}"/api
	dodir /etc/portage
	keepdir /etc/portage
}

pkg_preinst() {
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
	python_mod_optimize /usr/$(get_libdir)/portage/pym

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

	if [ x$MINOR_UPGRADE = x0 ] ; then
		elog "If you're upgrading from a pre-2.2 version of portage you might"
		elog "want to remerge world (emerge -e world) to take full advantage"
		elog "of some of the new features in 2.2."
		elog "This is not required however for portage to function properly."
		elog
	fi
}

pkg_postrm() {
	python_mod_cleanup /usr/$(get_libdir)/portage/pym
}
