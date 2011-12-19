# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id: portage-2.2.01.16270.ebuild 58665 2010-09-05 19:54:38Z grobian $

RESTRICT="test"

# Require EAPI 2 since we now require at least python-2.6 (for python 3
# syntax support) which also requires EAPI 2.
EAPI=2
inherit eutils multilib python

DESCRIPTION="Prefix branch of the Portage Package Manager, used in Gentoo Prefix"
HOMEPAGE="http://www.gentoo.org/proj/en/gentoo-alt/prefix/"
LICENSE="GPL-2"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
SLOT="0"
IUSE="build doc epydoc ipc linguas_pl selinux prefix-chaining"

python_dep=">=dev-lang/python-2.7 <dev-lang/python-3.0"

# The pysqlite blocker is for bug #282760.
DEPEND="${python_dep}
	!build? ( >=sys-apps/sed-4.0.5 )
	doc? ( app-text/xmlto ~app-text/docbook-xml-dtd-4.4 )
	epydoc? ( >=dev-python/epydoc-2.0 !<=dev-python/pysqlite-2.4.1 )"
# Require sandbox-2.2 for bug #288863.
RDEPEND="${python_dep}
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
	selinux? ( || ( >=sys-libs/libselinux-2.0.94[python] <sys-libs/libselinux-2.0.94 ) )
	!<app-shells/bash-3.2_p17"
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

	epatch "${FILESDIR}"/${PN}-2.2.01.19981-ebuildshell.patch
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
	./pym/portage/tests/runTests || \
		die "test(s) failed"
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
		doman -i18n=pl "${S_PL}"/man/pl/*.[0-9]
		doman -i18n=pl_PL.UTF-8 "${S_PL}"/man/pl_PL.UTF-8/*.[0-9]
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
	if [ -f "${EROOT}/etc/make.globals" ]; then
		rm "${EROOT}/etc/make.globals"
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
