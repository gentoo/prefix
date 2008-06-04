# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"
RESTRICT="mirror"

inherit toolchain-funcs eutils flag-o-matic python multilib

DESCRIPTION="Prefix branch of the Portage Package Management System. The primary package management and distribution system for Gentoo."
HOMEPAGE="http://www.gentoo.org/proj/en/gentoo-alt/prefix/"
LICENSE="GPL-2"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
PROVIDE="virtual/portage"
SLOT="0"
# USE_EXPAND_HIDDEN hides ELIBC and USERLAND expansions from emerge output (see make.conf.5).
IUSE_ELIBC="elibc_glibc elibc_uclibc elibc_FreeBSD"
IUSE_KERNEL="kernel_linux"
IUSE="build doc epydoc selinux linguas_pl ${IUSE_ELIBC} ${IUSE_KERNEL}"
DEPEND=">=dev-lang/python-2.4
	!build? ( >=sys-apps/sed-4.0.5 )
	doc? ( app-text/xmlto ~app-text/docbook-xml-dtd-4.4 )
	epydoc? ( >=dev-python/epydoc-2.0 )"
RDEPEND=">=dev-lang/python-2.4
	!build? ( >=sys-apps/sed-4.0.5
		>=app-shells/bash-3.2_p17 )
	!prefix? ( elibc_FreeBSD? ( sys-freebsd/freebsd-bin ) )
	elibc_glibc? ( >=sys-apps/sandbox-1.2.17 )
	elibc_uclibc? ( >=sys-apps/sandbox-1.2.17 )
	kernel_linux? ( >=app-misc/pax-utils-0.1.13 )
	kernel_SunOS? ( >=app-misc/pax-utils-0.1.13 )
	kernel_FreeBSD? ( >=app-misc/pax-utils-0.1.13 )
	selinux? ( >=dev-python/python-selinux-2.16 )"
PDEPEND="
	!build? (
		>=net-misc/rsync-2.6.4
		userland_GNU? ( >=sys-apps/coreutils-6.4 )
		|| ( >=dev-lang/python-2.5 >=dev-python/pycrypto-2.0.1-r6 )
	)"
# coreutils-6.4 rdep is for date format in emerge-webrsync #164532
# rsync-2.6.4 rdep is for the --filter option #167668
SRC_ARCHIVES="http://dev.gentoo.org/~grobian/distfiles"

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
#mirror://gentoo/prefix-${PN}-${PV}.tar.bz2
SRC_URI="
	${SRC_ARCHIVES}/prefix-${PN}-${PV}.tar.bz2
	linguas_pl? ( mirror://gentoo/${PN}-man-pl-${PV_PL}.tar.bz2
	${SRC_ARCHIVES}/${PN}-man-pl-${PV_PL}.tar.bz2 )"

#PATCHVER=${PVR}  # in prefix we don't do this
if [ -n "${PATCHVER}" ]; then
	SRC_URI="${SRC_URI} mirror://gentoo/${PN}-${PATCHVER}.patch.bz2
	${SRC_ARCHIVES}/${PN}-${PATCHVER}.patch.bz2"
fi

S="${WORKDIR}"/prefix-${PN}-${PV}
S_PL="${WORKDIR}"/${PN}-${PV_PL}

pkg_setup() {
	MINOR_UPGRADE=$(has_version '>=sys-apps/portage-2.2_alpha' && echo true)

	[[ -n ${PREFIX_PORTAGE_DONT_CHECK_MY_REPO} ]] && return
	[[ $(type -P svn) == "" ]] && return

	# This function is EVIL by definition because it dies, however, given that
	# infra really wants to expel http access we have no choice.
	# http://thread.gmane.org/gmane.linux.gentoo.devel.announce/98
	SYNC=$(cd "${PORTDIR}" && svn info | grep "^URL: " | cut -c6-)
	if [[ ${SYNC} == "http://overlays.gentoo.org/svn/proj/alt/trunk/prefix-overlay" ]] ; then
		ebeep
		eerror "You are currently using a Subversion Portage tree that uses"
		eerror "the HTTP protocol.  This protocol is scheduled for removal."
		eerror "If you need HTTP because of a firewall, please file a bug."
		eerror "See:"
		eerror "  http://thread.gmane.org/gmane.linux.gentoo.devel.announce/98"
		echo
		eerror "You need to switch your SVN checkout from HTTP to the SVN"
		eerror "protocol.  To do this, cd to"
		eerror "  ${EPREFIX}/usr/portage"
		eerror "and execute the following command"
		eerror "  svn switch --relocate \\"
		eerror "    http://overlays.gentoo.org/svn/proj/alt/trunk/prefix-overlay \\"
		eerror "    svn://overlays.gentoo.org/proj/alt/trunk/prefix-overlay"
		echo
		eerror "Developers can switch to https instead."
		echo
		eerror "Upgrading Portage is aborted now, as it is very important"
		eerror "that you switch now.  Try emerging again after your switched"
		eerror "your SVN checkout."
		ebeep
		die "please switch your SVN checkout"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	if [ -n "${PATCHVER}" ]; then
		cd "${S}"
		epatch "${WORKDIR}/${PN}-${PATCHVER}.patch"
	fi
}

src_compile() {
	econf \
		--with-portage-user="${PORTAGE_USER:-portage}" \
		--with-portage-group="${PORTAGE_GROUP:-portage}" \
		--with-root-user="$(python -c 'from portage.const import rootuser; print rootuser')" \
		--with-offset-prefix="${EPREFIX}" \
		--with-default-path="/usr/bin:/bin" \
		|| die "econf failed"
	emake || die "emake failed"

	if use elibc_FreeBSD; then
		cd "${S}"/src/bsd-flags
		chmod +x setup.py
		./setup.py build || die "Failed to install bsd-chflags module"
	fi

	if use doc; then
		cd "${S}"/doc
		touch fragment/date
		make xhtml xhtml-nochunks || die "failed to make docs"
	fi

	if use epydoc; then
		einfo "Generating api docs"
		mkdir "${WORKDIR}"/api
		local my_modules
		my_modules="$(find "${S}/pym" -name "*.py" \
			| sed -e 's:/__init__.py$::' -e 's:\.py$::' -e "s:^${S}/pym/::" \
			 -e 's:/:.:g' | sort)" || die "error listing modules"
		PYTHONPATH="${S}/pym:${PYTHONPATH}" epydoc -o "${WORKDIR}"/api \
			-qqqqq --no-frames --show-imports \
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

	make DESTDIR="${D}" install || die "make install failed."
	dodir /usr/lib/portage/bin

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

	echo "PYTHONPATH=\"${EPREFIX}${portage_base}/pym\"" > "${WORKDIR}"/05portage.envd
	doenvd "${WORKDIR}"/05portage.envd
}

pkg_preinst() {
	if ! use build && ! has_version dev-python/pycrypto && \
		has_version '>=dev-lang/python-2.5' ; then
		if ! built_with_use '>=dev-lang/python-2.5' ssl ; then
			ewarn "If you are an ebuild developer and you plan to commit ebuilds"
			ewarn "with this system then please install dev-python/pycrypto or"
			ewarn "enable the ssl USE flag for >=dev-lang/python-2.5 in order"
			ewarn "to enable RMD160 hash support."
			ewarn "See bug #198398 for more information."
		fi
	fi

	if [[ ! -e ${EROOT}/var/lib/portage/world_sets ]] ; then
		ewarn "This version of Portage has 'sets' stored separately.  Your"
		ewarn "'world' file is now automatically split into multiple files"
		ewarn "to reflect the new situation.  A backup of your 'world' file"
		ewarn "is stored at:"
		ewarn "  ${EPREFIX}/var/lib/portage/world.pre-sets-split"
		ewarn "If your installation appears to works fine, it is safe to"
		ewarn "remove the backup file."
		cp -a "${EPREFIX}"/var/lib/portage/world{,.pre-sets-split}
		grep "^@" "${EPREFIX}"/var/lib/portage/world > \
			"${EPREFIX}"/var/lib/portage/world_sets
		sed -i -e '/^@/d' "${EPREFIX}"/var/lib/portage/world
	fi

	einfo "converting NEEDED files to new syntax, please wait"
	cd "${EROOT}/var/db/pkg"
	for cpv in */*/NEEDED ; do
		if [[ ${CHOST} == *-darwin* && ! -f ${cpv}.MACHO.2 ]] ; then
			while read line; do
				filename=${line% *}
				needed=${line#* }
				install_name=$(otool -DX "${filename}")
				echo "${filename};${install_name};${needed}" >> "${cpv}".MACHO.2
			done < "${cpv}"
		elif [[ ${CHOST} != *-darwin* && ! -f ${cpv}.ELF.2 ]] ; then
			while read line; do
				filename=${line% *}
				needed=${line#* }
				newline=$(scanelf -BF "%a;%F;%S;$needed;%r" $filename)
				echo "${newline:3}" >> "${cpv}".ELF.2
			done < "${cpv}"
		fi
	done
}

pkg_postinst() {
	for x in ${EROOT}/etc/._cfg????_make.globals; do
		# Overwrite the globals file automatically.
		[ -e "${x}" ] && mv -f "${x}" "${EROOT}/etc/make.globals"
	done

	# Compile all source files recursively. Any orphans
	# will be identified and removed in postrm.
	python_mod_optimize /usr/$(get_libdir)/portage/pym

	elog
	elog "For help with using portage please consult the Gentoo Handbook"
	elog "at http://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=3"
	elog

	if [ -z "${MINOR_UPGRADE}" ]; then
		elog "If you're upgrading from a pre-2.2 version of portage you might"
		elog "want to remerge world (emerge -e world) to take full advantage"
		elog "of some of the new features in 2.2."
		elog "This is not required however for portage to function properly."
		elog
	fi

	if [ -z "${PV/*_pre*}" ]; then
		elog "If you always want to use the latest development version of portage"
		elog "please read http://www.gentoo.org/proj/en/portage/doc/testing.xml"
		elog
	fi
}

pkg_postrm() {
	python_mod_cleanup /usr/$(get_libdir)/portage/pym
}
