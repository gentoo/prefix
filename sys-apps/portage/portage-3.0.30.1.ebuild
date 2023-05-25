# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DISTUTILS_USE_SETUPTOOLS=no
PYTHON_COMPAT=( pypy3 python3_{9..11} )
PYTHON_REQ_USE='bzip2(+),threads(+)'

inherit distutils-r1 linux-info systemd prefix

DESCRIPTION="Portage package manager used in Gentoo Prefix"
HOMEPAGE="https://wiki.gentoo.org/wiki/Project:Portage"

LICENSE="GPL-2"
KEYWORDS="~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~x64-solaris"
SLOT="0"
IUSE="apidoc build doc gentoo-dev +ipc +native-extensions rsync-verify selinux test xattr"
RESTRICT="!test? ( test )"

BDEPEND="
	app-arch/xz-utils
	test? ( dev-vcs/git )"
DEPEND="!build? ( $(python_gen_impl_dep 'ssl(+)') )
	>=app-arch/tar-1.27
	dev-lang/python-exec:2
	>=sys-apps/sed-4.0.5 sys-devel/patch
	doc? ( app-text/xmlto ~app-text/docbook-xml-dtd-4.4 )
	apidoc? (
		dev-python/sphinx
		dev-python/sphinx-epytext
	)"
# Require sandbox-2.2 for bug #288863.
# For whirlpool hash, require python[ssl] (bug #425046).
# For compgen, require bash[readline] (bug #445576).
# app-portage/gemato goes without PYTHON_USEDEP since we're calling
# the executable.
RDEPEND="
	!prefix? ( acct-user/portage )
	app-arch/zstd
	>=app-arch/tar-1.27
	dev-lang/python-exec:2
	>=sys-apps/findutils-4.4
	!build? (
		>=sys-apps/sed-4.0.5
		>=app-shells/bash-5.0:0[readline]
		>=app-admin/eselect-1.2
		rsync-verify? (
			>=app-portage/gemato-14.5[${PYTHON_USEDEP}]
			>=sec-keys/openpgp-keys-gentoo-release-20180706
			>=app-crypt/gnupg-2.2.4-r2[ssl(-)]
		)
	)
	elibc_glibc? ( !prefix? ( >=sys-apps/sandbox-2.2 ) )
	elibc_musl? ( >=sys-apps/sandbox-2.2 )
	kernel_linux? ( sys-apps/util-linux )
	>=app-misc/pax-utils-0.1.18
	selinux? ( >=sys-libs/libselinux-2.0.94[python,${PYTHON_USEDEP}] )
	xattr? ( kernel_linux? (
		>=sys-apps/install-xattr-0.3
	) )
	!<app-admin/logrotate-3.8.0
	!<app-portage/gentoolkit-0.4.6
	!<app-portage/repoman-2.3.10
	!~app-portage/repoman-3.0.0"
PDEPEND="
	!build? (
		>=net-misc/rsync-2.6.4
		>=sys-apps/file-5.41
		>=sys-apps/coreutils-6.4
	)"
# coreutils-6.4 rdep is for date format in emerge-webrsync #164532
# NOTE: FEATURES=installsources requires debugedit and rsync

SRC_ARCHIVES="https://dev.gentoo.org/~zmedico/portage/archives https://dev.gentoo.org/~grobian/distfiles"

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

pkg_pretend() {
	local CONFIG_CHECK="~IPC_NS ~PID_NS ~NET_NS ~UTS_NS"

	check_extra_config
}

python_prepare_all() {
	distutils-r1_python_prepare_all

	eapply "${FILESDIR}"/${PN}-3.0.30-prefix-stack.patch # 658572
	eapply "${FILESDIR}"/${PN}-3.0.30-ebuildshell.patch # 155161
	eapply "${FILESDIR}"/${PN}-3.0.30-interrevisions.patch # 832062
	if use gentoo-dev; then
		einfo "Disabling --dynamic-deps by default for gentoo-dev..."
		sed -e 's:\("--dynamic-deps", \)\("y"\):\1"n":' \
			-i lib/_emerge/create_depgraph_params.py || \
			die "failed to patch create_depgraph_params.py"

		einfo "Enabling additional FEATURES for gentoo-dev..."
		echo 'FEATURES="${FEATURES} strict-keepdir"' \
			>> cnf/make.globals || die
	fi

	if use native-extensions; then
		printf "[build_ext]\nportage_ext_modules=true\n" >> \
			setup.cfg || die
	fi

	if ! use ipc ; then
		einfo "Disabling ipc..."
		sed -e "s:_enable_ipc_daemon = True:_enable_ipc_daemon = False:" \
			-i lib/_emerge/AbstractEbuildProcess.py || \
			die "failed to patch AbstractEbuildProcess.py"
	fi

	if use xattr && use kernel_linux ; then
		einfo "Adding FEATURES=xattr to make.globals ..."
		echo -e '\nFEATURES="${FEATURES} xattr"' >> cnf/make.globals \
			|| die "failed to append to make.globals"
	fi

	if use build || ! use rsync-verify; then
		sed -e '/^sync-rsync-verify-metamanifest/s|yes|no|' \
			-e '/^sync-webrsync-verify-signature/s|yes|no|' \
			-i cnf/repos.conf || die "sed failed"
	fi

	if [[ -n ${EPREFIX} ]] ; then
		# PREFIX LOCAL: only hack const_autotool
		local extrapath="/usr/sbin:/usr/bin:/sbin:/bin"
		# ok, we can't rely on PORTAGE_ROOT_USER being there yet, as people
		# tend not to update that often, as long as we are a separate ebuild
		# we can assume when unset, it's time for some older trick
		if [[ -z ${PORTAGE_ROOT_USER} ]] ; then
			PORTAGE_ROOT_USER=$(python -c 'from portage.const import rootuser; print rootuser')
		fi
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
			-e "s|@EXTRA_PATH@|${extrapath}|" \
			-e "s|@portagegroup@|${PORTAGE_GROUP:-portage}|" \
			-e "s|@portageuser@|${PORTAGE_USER:-portage}|" \
			-e "s|@rootuser@|${PORTAGE_ROOT_USER:-root}|" \
			-e "s|@rootuid@|$(id -u ${PORTAGE_ROOT_USER:-root})|" \
			-e "s|@rootgid@|$(id -g ${PORTAGE_ROOT_USER:-root})|" \
			-e "s|@sysconfdir@|${EPREFIX}/etc|" \
			-i '{}' + || \
			die "Failed to patch sources"
		# We don't need the below, since setup.py deals with this (and
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
		done < <(find . -type f ! -name etc-update -print0)

		einfo "Setting gentoo_prefix as reponame for emerge-webrsync"
		sed -i -e 's/repo_name=gentoo/repo_name=gentoo_prefix/' \
			bin/emerge-webrsync || die

		einfo "Making absent gemato non-fatal"
		sed -i -e '/exitcode = 127/d' \
			lib/portage/sync/modules/rsync/rsync.py || die
		# END PREFIX LOCAL
	fi

	# PREFIX LOCAL: make.conf is written by bootstrap-prefix.sh
	if use !prefix ; then
	cd "${S}/cnf" || die
	if [ -f "make.conf.example.${ARCH}".diff ]; then
		patch make.conf.example "make.conf.example.${ARCH}".diff || \
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
	use apidoc && targets+=( apidoc )

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
	use doc && targets+=(
		install_docbook
		--htmldir="${EPREFIX}/usr/share/doc/${PF}/html"
	)
	use apidoc && targets+=(
		install_apidoc
		--htmldir="${EPREFIX}/usr/share/doc/${PF}/html"
	)

	# install docs
	if [[ ${targets[@]} ]]; then
		esetup.py "${targets[@]}"
	fi

	dotmpfiles "${FILESDIR}"/portage-ccache.conf

	# Due to distutils/python-exec limitations
	# these must be installed to /usr/bin.
	local sbin_relocations='archive-conf dispatch-conf emaint env-update etc-update fixpackages regenworld'
	einfo "Moving admin scripts to the correct directory"
	dodir /usr/sbin
	for target in ${sbin_relocations}; do
		einfo "Moving /usr/bin/${target} to /usr/sbin/${target}"
		mv "${ED}/usr/bin/${target}" "${ED}/usr/sbin/${target}" || die "sbin scripts move failed!"
	done
}

pkg_preinst() {
	python_setup
	local sitedir=$(python_get_sitedir)
	[[ -d ${D}${sitedir} ]] || die "${D}${sitedir}: No such directory"
	env -u DISTDIR \
		-u PORTAGE_OVERRIDE_EPREFIX \
		-u PORTAGE_REPOSITORIES \
		-u PORTDIR \
		-u PORTDIR_OVERLAY \
		PYTHONPATH="${D}${sitedir}${PYTHONPATH:+:${PYTHONPATH}}" \
		"${PYTHON}" -m portage._compat_upgrade.default_locations || die

	env -u BINPKG_COMPRESS -u PORTAGE_REPOSITORIES \
		PYTHONPATH="${D}${sitedir}${PYTHONPATH:+:${PYTHONPATH}}" \
		"${PYTHON}" -m portage._compat_upgrade.binpkg_compression || die

	env -u FEATURES -u PORTAGE_REPOSITORIES \
		PYTHONPATH="${D}${sitedir}${PYTHONPATH:+:${PYTHONPATH}}" \
		"${PYTHON}" -m portage._compat_upgrade.binpkg_multi_instance || die

	# elog dir must exist to avoid logrotate error for bug #415911.
	# This code runs in preinst in order to bypass the mapping of
	# portage:portage to root:root which happens after src_install.
	keepdir /var/log/portage/elog
	# This is allowed to fail if the user/group are invalid for prefix users.
	if chown ${PORTAGE_USER}:${PORTAGE_GROUP} "${ED}"/var/log/portage{,/elog} 2>/dev/null ; then
		chmod g+s,ug+rwx "${ED}"/var/log/portage{,/elog}
	fi

	if has_version "<${CATEGORY}/${PN}-2.3.77"; then
		elog "The emerge --autounmask option is now disabled by default, except for"
		elog "portions of behavior which are controlled by the --autounmask-use and"
		elog "--autounmask-license options. For backward compatibility, previous"
		elog "behavior of --autounmask=y and --autounmask=n is entirely preserved."
		elog "Users can get the old behavior simply by adding --autounmask to the"
		elog "make.conf EMERGE_DEFAULT_OPTS variable. For the rationale for this"
		elog "change, see https://bugs.gentoo.org/658648."
	fi
}
