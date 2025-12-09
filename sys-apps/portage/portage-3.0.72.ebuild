# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( pypy3 python3_{10..13} )
PYTHON_REQ_USE='bzip2(+),threads(+)'
TMPFILES_OPTIONAL=1

inherit meson linux-info multiprocessing python-r1 tmpfiles

DESCRIPTION="The package management and distribution system for Gentoo Prefix"
HOMEPAGE="https://wiki.gentoo.org/wiki/Project:Portage"

if [[ ${PV} == 9999 ]] ; then
	EGIT_REPO_URI="
		https://anongit.gentoo.org/git/proj/portage.git
		https://github.com/gentoo/portage.git
	"
	inherit git-r3
else
	SRC_URI="https://dev.gentoo.org/~grobian/distfiles/prefix-${P}.tar.bz2"
	KEYWORDS="~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~x64-solaris"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="apidoc build doc gentoo-dev +ipc +native-extensions +rsync-verify selinux test xattr"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="!test? ( test )"

# setuptools is still needed as a workaround for Python 3.12+ for now.
# https://github.com/mesonbuild/meson/issues/7702
#
# >=meson-1.2.1-r1 for bug #912051
BDEPEND="
	${PYTHON_DEPS}
	>=dev-build/meson-1.2.1-r1
	$(python_gen_cond_dep '
		dev-python/setuptools[${PYTHON_USEDEP}]
	' python3_12)
	test? (
		dev-python/pytest-xdist[${PYTHON_USEDEP}]
		dev-vcs/git
	)
"
DEPEND="
	${PYTHON_DEPS}
	>=app-arch/tar-1.27
	dev-lang/python-exec:2
	>=sys-apps/sed-4.0.5
	sys-devel/patch
	!build? ( $(python_gen_impl_dep 'ssl(+)') )
	apidoc? (
		dev-python/sphinx[${PYTHON_USEDEP}]
		dev-python/sphinx-epytext[${PYTHON_USEDEP}]
	)
	doc? (
		~app-text/docbook-xml-dtd-4.4
		app-text/xmlto
	)
"
# Require sandbox-2.2 for bug #288863.
# For whirlpool hash, require python[ssl] (bug #425046).
RDEPEND="
	${PYTHON_DEPS}
	!prefix? ( acct-user/portage )
	>=app-arch/tar-1.27
	app-arch/zstd
	>=app-misc/pax-utils-0.1.17
	dev-lang/python-exec:2
	>=sys-apps/baselayout-2.9
	>=sys-apps/findutils-4.9
	!build? (
		>=app-admin/eselect-1.2
		!prefix? ( app-portage/getuto )
		>=app-shells/bash-5.0:0
		>=sec-keys/openpgp-keys-gentoo-release-20230329
		>=sys-apps/sed-4.0.5
		rsync-verify? (
			>=app-crypt/gnupg-2.2.4-r2[ssl(-)]
			>=app-portage/gemato-14.5[${PYTHON_USEDEP}]
		)
	)
	elibc_glibc? ( !prefix? ( >=sys-apps/sandbox-2.2 ) )
	elibc_musl? ( !prefix? ( >=sys-apps/sandbox-2.2 ) )
	kernel_linux? ( sys-apps/util-linux )
	selinux? ( >=sys-libs/libselinux-2.0.94[python,${PYTHON_USEDEP}] )
	xattr? ( kernel_linux? (
		>=sys-apps/install-xattr-0.3
	) )
	!<app-admin/logrotate-3.8.0
	!<app-portage/gentoolkit-0.4.6
	!<app-portage/repoman-2.3.10
	!~app-portage/repoman-3.0.0
"
# coreutils-6.4 rdep is for date format in emerge-webrsync #164532
# NOTE: FEATURES=installsources requires debugedit and rsync
PDEPEND="
	!build? (
		>=net-misc/rsync-2.6.4
		>=sys-apps/coreutils-6.4
		>=sys-apps/file-5.44-r3
	)
"

S="${WORKDIR}"/prefix-${P}

PATCHES=(
	"${FILESDIR}"/${PN}-3.0.55.1-interrevisions.patch
)

pkg_pretend() {
	local CONFIG_CHECK="~IPC_NS ~PID_NS ~NET_NS ~UTS_NS"

	check_extra_config
}

src_prepare() {
	default

	if use prefix-guest; then
		sed -e "s|^\(main-repo = \).*|\\1gentoo_prefix|" \
			-e "s|^\\[gentoo\\]|[gentoo_prefix]|" \
			-e "s|^\(sync-uri = \).*|\\1rsync://rsync.prefix.bitzolder.nl/gentoo-portage-prefix|" \
			-i cnf/repos.conf || die "sed failed"

		# PREFIX LOCAL: do the work of configure with expansions here
		P_GROUP=${PORTAGE_GRPNAME}
		P_USER=${PORTAGE_USERNAME}
		[[ -z ${P_GROUP} ]] && \
			P_GROUP=$(python -c 'from portage.const import portagegroup; print(portagegroup)')
		[[ -z ${P_USER} ]] && \
			P_USER=$(python -c 'from portage.const import portageuser; print(portageuser)')
		[[ -z ${P_GROUP}     ]] && P_GROUP=portage
		[[ -z ${P_USER}      ]] && P_USER=portage
		P_GID=$(python -c "import grp; print(grp.getgrnam('${P_GROUP}').gr_gid)")
		P_UID=$(id -u ${P_USER})

		# We need to probe for bash in the Prefix, because it may not
		# exist, in which case we fall back to the currently in use
		# bash.  This logic is necessary in particular during bootstrap,
		# where we pull ourselves out of a temporary place with tools
		local bash="${EPREFIX}/bin/bash"
		[[ ! -x ${bash} ]] && bash=${BASH}

		einfo "Adjusting sources for ${EPREFIX}"
		sed -e "s|@PORTAGE_EPREFIX@|${EPREFIX}|" \
			-e "s|@PORTAGE_MV@|$(type -P mv)|" \
			-e "s|@PORTAGE_BASH@|${bash}|" \
			-e "s|@portagegroup@|${P_GROUP}|" \
			-e "s|@portageuser@|${P_USER}|" \
			-e "s|@rootuid@|${P_UID}|" \
			-e "s|@rootgid@|${P_GID}|" \
			-e "s|@sysconfdir@|${EPREFIX}/etc|" \
			-i \
			lib/portage/const_autotool.py cnf/make.globals \
			|| die "Failed to patch sources"

		sed -e "s|@PREFIX_PORTAGE_PYTHON@|$(type -P python)|" \
			-i \
			bin/ebuild-helpers/dohtml \
			bin/ebuild-pyhelper \
			bin/misc-functions.sh \
			bin/phase-functions.sh \
			|| die "Failed to patch sources"

		# remove Makefiles, or else they will get installed
		#find . -name "Makefile.*" -delete

#		einfo "Prefixing shebangs ..."
#		find . -type f ! -name etc-update | \
#		while read -r line; do
#			[[ -x ${line} || ${line} == *".py" ]] || continue;
#			local shebang=$(head -n1 "${line}")
#			if [[ ${shebang} == "#!"* && ! ${shebang} == "#!${EPREFIX}/"* ]] ;
#			then
#				sed -i -e "1s:.*:#!${EPREFIX}${shebang:2}:" "${line}" || \
#					die "sed failed"
#			fi
#		done

		einfo "Setting gentoo_prefix as reponame for emerge-webrsync"
		sed -i -e 's/repo_name=gentoo/repo_name=gentoo_prefix/' \
			bin/emerge-webrsync || die

		einfo "Making absent gemato non-fatal"
		sed -i -e '/exitcode = 127/d' \
			lib/portage/sync/modules/rsync/rsync.py || die
		# END PREFIX LOCAL
	fi
}

src_configure() {
	local code_only=false
	python_foreach_impl my_src_configure
}

my_src_configure() {
	local emesonargs=(
		-Dcode-only=${code_only}
		-Deprefix="${EPREFIX}"
		-Dportage-bindir="${EPREFIX}/usr/lib/portage/${EPYTHON}"
		-Ddocdir="${EPREFIX}/usr/share/doc/${PF}"
		$(meson_use doc)
		$(meson_use apidoc)
		$(meson_use gentoo-dev)
		$(meson_use ipc)
		$(meson_use xattr)
	)

	if use native-extensions && [[ "${EPYTHON}" != "pypy3" ]] ; then
		emesonargs+=( -Dnative-extensions=true )
	else
		emesonargs+=( -Dnative-extensions=false )
	fi

	if use build; then
		emesonargs+=( -Drsync-verify=false )
	else
		emesonargs+=( $(meson_use rsync-verify) )
	fi

	meson_src_configure
	code_only=true
}

src_compile() {
	python_foreach_impl meson_src_compile
}

src_test() {
	local -x PYTEST_ADDOPTS="-vv -ra -l -o console_output_style=count -n $(makeopts_jobs) --dist=worksteal"

	python_foreach_impl meson_src_test --no-rebuild --verbose
}

src_install() {
	python_foreach_impl my_src_install
	dotmpfiles "${FILESDIR}"/portage-{ccache,tmpdir}.conf

	local scripts
	mapfile -t scripts < <(awk '/^#!.*python/ {print FILENAME} {nextfile}' "${ED}"/usr/{bin,sbin}/* || die)
	python_replicate_script "${scripts[@]}"
}

my_src_install() {
	local pydirs=(
		"${D}$(python_get_sitedir)"
		"${ED}/usr/lib/portage/${EPYTHON}"
	)

	meson_src_install
	python_optimize "${pydirs[@]}"
	python_fix_shebang "${pydirs[@]}"
}

pkg_preinst() {
	if ! use build && [[ -z ${ROOT} ]]; then
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
	fi

	# elog dir must exist to avoid logrotate error for bug #415911.
	# This code runs in preinst in order to bypass the mapping of
	# portage:portage to root:root which happens after src_install.
	keepdir /var/log/portage/elog
	# This is allowed to fail if the user/group are invalid for prefix users.
	if chown portage:portage "${ED}"/var/log/portage{,/elog} 2>/dev/null ; then
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

pkg_postinst() {
	# Warn about obsolete "enotice" script, bug #867010
	local bashrc=${EROOT}/etc/portage/profile/profile.bashrc
	if [[ -e ${bashrc} ]] && grep -q enotice "${bashrc}"; then
		eerror "Obsolete 'enotice' script detected!"
		eerror "Please remove this from ${bashrc} to avoid problems."
		eerror "See bug 867010 for more details."
	fi

	# migrate to setup where user/group are in the users' config
	if use prefix-guest; then
		python_setup

		local P_USER=$(
			env -u PORTAGE_USERNAME \
				"${PYTHON}" -c 'from portage.data import _portage_username; print(_portage_username)')
		if [[ ${P_USER} != ${PORTAGE_USERNAME} ]] ; then
			elog "Your Portage configuration is incomplete."
			elog "Due to a change in how Prefix Portage handles user and group"
			elog "administration, you must add the following in your"
			elog "  ${EROOT}/etc/portage/make.conf"
			elog "PORTAGE_USERNAME=\"${PORTAGE_USERNAME}\""
			elog "PORTAGE_GRPNAME=\"${PORTAGE_GRPNAME}\""
			elog "PORTAGE_INST_UID=\"${PORTAGE_INST_UID}\""
			elog "PORTAGE_INST_GID=\"${PORTAGE_INST_GID}\""
			eerror "your installation will break without these settings"

			local conffile="${EROOT}/etc/portage/make.conf"
			if [[ -d ${conffile} ]] ; then
				local f
				for f in ${conffile}/* ; do
					if [[ -w ${f} ]] ; then
						conffile=${f}
						break;
					fi
				done
			fi
			if [[ ! -w ${conffile} ]] ; then
				eerror "could not find a file in your make.conf to write to"
				eerror "you must add the variables yourself!"
			else
				{
					echo ""
					echo "# added by ${P} at $(date)"
					echo "# this was done as part of a migration of these"
					echo "# values from make.globals to user configuration"
					echo "PORTAGE_USERNAME=\"${PORTAGE_USERNAME}\""
					echo "PORTAGE_GRPNAME=\"${PORTAGE_GRPNAME}\""
					echo "PORTAGE_INST_UID=\"${PORTAGE_INST_UID}\""
					echo "PORTAGE_INST_GID=\"${PORTAGE_INST_GID}\""
				} >> "${conffile}"
				elog "user configuration variables were automatically added"
				elog "to your ${conffile}, please review"
			fi
		fi
	fi
}
