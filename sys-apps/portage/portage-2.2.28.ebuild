# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

PYTHON_COMPAT=(
	pypy
	python3_3 python3_4 python3_5
	python2_7
)
PYTHON_REQ_USE='bzip2(+)'

inherit eutils distutils-r1 multilib

DESCRIPTION="Portage package manager used in Gentoo Prefix"
HOMEPAGE="http://prefix.gentoo.org/"
LICENSE="GPL-2"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
SLOT="0"
IUSE="build doc epydoc +ipc linguas_ru selinux xattr prefix-chaining"

DEPEND="!build? ( $(python_gen_impl_dep 'ssl(+)') )
	>=sys-devel/make-3.82
	>=app-arch/tar-1.27
	dev-lang/python-exec:2
	>=sys-apps/sed-4.0.5 sys-devel/patch
	doc? ( app-text/xmlto ~app-text/docbook-xml-dtd-4.4 )
	epydoc? ( >=dev-python/epydoc-2.0[$(python_gen_usedep 'python2*')] )"
# Require sandbox-2.2 for bug #288863.
# For xattr, we can spawn getfattr and setfattr from sys-apps/attr, but that's
# quite slow, so it's not considered in the dependencies as an alternative to
# to python-3.3 / pyxattr. Also, xattr support is only tested with Linux, so
# for now, don't pull in xattr deps for other kernels.
# For whirlpool hash, require python[ssl] (bug #425046).
# For compgen, require bash[readline] (bug #445576).
RDEPEND="
	>=app-arch/tar-1.27
	dev-lang/python-exec:2
	!build? (
		>=sys-apps/sed-4.0.5
		app-shells/bash:0[readline]
		>=app-admin/eselect-1.2
	)
	elibc_FreeBSD? ( !prefix? ( sys-freebsd/freebsd-bin ) )
	elibc_glibc? ( !prefix? ( >=sys-apps/sandbox-2.2 ) )
	elibc_uclibc? ( !prefix? ( >=sys-apps/sandbox-2.2 ) )
	kernel_linux? ( >=app-misc/pax-utils-0.1.17 )
	kernel_SunOS? ( >=app-misc/pax-utils-0.1.17 )
	kernel_FreeBSD? ( >=app-misc/pax-utils-0.1.17 )
	kernel_Darwin? ( >=app-misc/pax-utils-0.1.18 )
	kernel_HPUX? ( !hppa-hpux? ( >=app-misc/pax-utils-0.1.19 ) )
	kernel_AIX? ( >=sys-apps/aix-miscutils-0.1.1634 )
	selinux? ( >=sys-libs/libselinux-2.0.94[python,${PYTHON_USEDEP}] )
	xattr? ( kernel_linux? (
		>=sys-apps/install-xattr-0.3
		$(python_gen_cond_dep 'dev-python/pyxattr[${PYTHON_USEDEP}]' \
			python2_7 pypy)
	) )
	!prefix? ( !<app-admin/logrotate-3.8.0 )"
PDEPEND="
	!build? (
		>=net-misc/rsync-2.6.4
		userland_GNU? ( >=sys-apps/coreutils-6.4 )
	)"
# coreutils-6.4 rdep is for date format in emerge-webrsync #164532
# NOTE: FEATURES=installsources requires debugedit and rsync

REQUIRED_USE="epydoc? ( $(python_gen_useflags 'python2*') )"

SRC_ARCHIVES="https://dev.gentoo.org/~dolsen/releases/portage http://dev.gentoo.org/~grobian/distfiles"

prefix_src_archives() {
	local x y
	for x in ${@}; do
		for y in ${SRC_ARCHIVES}; do
			echo ${y}/${x}
		done
	done
}

TARBALL_PV=${PV}
SRC_URI="mirror://gentoo/prefix-${PN}-${TARBALL_PV}.tar.bz2
	$(prefix_src_archives prefix-${PN}-${TARBALL_PV}.tar.bz2)"

S="${WORKDIR}"/prefix-${PN}-${TARBALL_PV}

pkg_setup() {
	use epydoc && DISTUTILS_ALL_SUBPHASE_IMPLS=( python2.7 )
}

python_prepare_all() {
	distutils-r1_python_prepare_all

	epatch "${FILESDIR}"/${PN}-2.2.8-ebuildshell.patch # 155161
	use prefix-chaining &&
		epatch "${FILESDIR}"/${PN}-2.2.14-prefix-chaining.patch

	# solved in git already, remove at next version
	sed -i -e "s/version = '2.2.27'/version = '2.2.27-prefix'/" \
		setup.py || die

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

	if [[ -n ${EPREFIX} ]] ; then
		# PREFIX LOCAL: only hack const_autotool
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
		local defaultpath="${EPREFIX}/usr/sbin:${EPREFIX}/usr/bin:${EPREFIX}/sbin:${EPREFIX}/bin"
		# We need to probe for bash in the Prefix, because it may not
		# exist, in which case we fall back to the currently in use
		# bash.  This logic is necessary in particular during bootstrap,
		# where we pull ourselves out of a temporary place with tools
		local bash="${EPREFIX}/bin/bash"
		[[ ! -x ${bash} ]] && bash=${BASH}

		einfo "Adjusting sources for ${EPREFIX}"
		find . -type f -exec \
		sed -e "s|@PORTAGE_EPREFIX@|${EPREFIX}|" \
			-e "s|@PORTAGE_MV@|$(type -P mv)|" \
			-e "s|@PORTAGE_BASH@|${bash}|" \
			-e "s|@PREFIX_PORTAGE_PYTHON@|$(type -P python)|" \
			-e "s|@DEFAULT_PATH@|${defaultpath}|" \
			-e "s|@EXTRA_PATH@|${extrapath}|" \
			-e "s|@portagegroup@|${PORTAGE_GROUP:-portage}|" \
			-e "s|@portageuser@|${PORTAGE_USER:-portage}|" \
			-e "s|@rootuser@|${PORTAGE_ROOT_USER:-root}|" \
			-e "s|@rootuid@|$(id -u ${PORTAGE_ROOT_USER:-root})|" \
			-e "s|@rootgid@|$(id -g ${PORTAGE_ROOT_USER:-root})|" \
			-e "s|@sysconfdir@|${EPREFIX}/etc|" \
			-i '{}' + || \
			die "Failed to patch sources"
		# We don't need the below, since setup.py deal with this (and
		# more) so we don't have to make this correct
		#	-e "s|@PORTAGE_BASE@|${EPREFIX}/usr/lib/portage/${EPYTHON}|" \

		# remove Makefiles, or else they will get installed
		find . -name "Makefile.*" -delete

		einfo "Prefixing shebangs ..."
		while read -r -d $'\0' ; do
			local shebang=$(head -n1 "$REPLY")
			if [[ ${shebang} == "#!"* && ! ${shebang} == "#!${EPREFIX}/"* ]] ; then
				sed -i -e "1s:.*:#!${EPREFIX}${shebang:2}:" "$REPLY" || \
					die "sed failed"
			fi
		done < <(find . -type f -print0)
		# END PREFIX LOCAL
	fi

	# PREFIX LOCAL: make.conf is written by bootstrap-prefix.sh
	if use !prefix ; then
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

python_compile_all() {
	local targets=()
	use doc && targets+=( docbook )
	use epydoc && targets+=( epydoc )

	if [[ ${targets[@]} ]]; then
		esetup.py "${targets[@]}"
	fi
}

python_test() {
	esetup.py test
}

python_install() {
	# Install sbin scripts to bindir for python-exec linking
	# they will be relocated in pkg_preinst()
	distutils-r1_python_install \
		--system-prefix="${EPREFIX}/usr" \
		--bindir="$(python_get_scriptdir)" \
		--docdir="${EPREFIX}/usr/share/doc/${PF}" \
		--htmldir="${EPREFIX}/usr/share/doc/${PF}/html" \
		--portage-bindir="${EPREFIX}/usr/lib/portage/${EPYTHON}" \
		--sbindir="$(python_get_scriptdir)" \
		--sysconfdir="${EPREFIX}/etc" \
		"${@}"
}

python_install_all() {
	distutils-r1_python_install_all

	local targets=()
	use doc && targets+=( install_docbook )
	use epydoc && targets+=( install_epydoc )

	# install docs
	if [[ ${targets[@]} ]]; then
		esetup.py "${targets[@]}"
	fi

	# Due to distutils/python-exec limitations
	# these must be installed to /usr/bin.
	local sbin_relocations='archive-conf dispatch-conf emaint env-update etc-update fixpackages regenworld'
	einfo "Moving admin scripts to the correct directory"
	dodir /usr/sbin
	for target in ${sbin_relocations}; do
		einfo "Moving /usr/bin/${target} to /usr/sbin/${target}"
		mv "${ED}usr/bin/${target}" "${ED}usr/sbin/${target}" || die "sbin scripts move failed!"
	done
}

pkg_preinst() {
	# comment out sanity test until it is fixed to work
	# with the new PORTAGE_PYM_PATH
	#if [[ $ROOT == / ]] ; then
		## Run some minimal tests as a sanity check.
		#local test_runner=$(find "${ED}" -name runTests)
		#if [[ -n $test_runner && -x $test_runner ]] ; then
			#einfo "Running preinst sanity tests..."
			#"$test_runner" || die "preinst sanity tests failed"
		#fi
	#fi

	# elog dir must exist to avoid logrotate error for bug #415911.
	# This code runs in preinst in order to bypass the mapping of
	# portage:portage to root:root which happens after src_install.
	keepdir /var/log/portage/elog
	# This is allowed to fail if the user/group are invalid for prefix users.
	if chown ${PORTAGE_USER}:${PORTAGE_GROUP} "${ED}"var/log/portage{,/elog} 2>/dev/null ; then
		chmod g+s,ug+rwx "${ED}"var/log/portage{,/elog}
	fi
}
