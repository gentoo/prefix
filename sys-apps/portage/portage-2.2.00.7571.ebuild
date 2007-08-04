# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="prefix"
RESTRICT="mirror"

inherit toolchain-funcs eutils flag-o-matic multilib

DESCRIPTION="Prefix branch of the Portage Package Management System. The primary package management and distribution system for Gentoo."
HOMEPAGE="http://www.gentoo.org/proj/en/gentoo-alt/prefix/"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~ia64 ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
PROVIDE="virtual/portage"
SLOT="0"
# USE_EXPAND_HIDDEN hides ELIBC and USERLAND expansions from emerge output (see make.conf.5).
IUSE_ELIBC="elibc_glibc elibc_uclibc elibc_FreeBSD"
IUSE_KERNEL="kernel_linux"
IUSE="build doc epydoc selinux linguas_pl ${IUSE_ELIBC} ${IUSE_USERLAND}"
DEPEND=">=dev-lang/python-2.4
	!build? ( >=sys-apps/sed-4.0.5 )
	epydoc? ( >=dev-python/epydoc-2.0 )"
RDEPEND=">=dev-lang/python-2.4
	!build? ( >=sys-apps/sed-4.0.5
		dev-python/python-fchksum
		>=app-shells/bash-3.0 )
	elibc_glibc? ( >=sys-apps/sandbox-1.2.17 )
	elibc_uclibc? ( >=sys-apps/sandbox-1.2.17 )
	kernel_linux? ( >=app-misc/pax-utils-0.1.13 )
	>=sys-apps/coreutils-6.4
	selinux? ( >=dev-python/python-selinux-2.16 )
	doc? ( app-portage/portage-manpages )
	>=dev-python/pycrypto-2.0.1-r5
	>=net-misc/rsync-2.6.4"
# coreutils-6.4 rdep is for date format in emerge-webrsync #164532
# rsync-2.6.4 rdep is for the --filter option #167668
SRC_ARCHIVES="http://dev.gentoo.org/~grobian/distfiles"

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

if [ -n "${PATCHVER_PL}" ]; then
	SRC_URI="${SRC_URI} linguas_pl? ( mirror://gentoo/${PN}-man-pl-${PV_PL}${PATCHVER_PL}.patch.bz2
	${SRC_ARCHIVES}/${PN}-man-pl-${PV_PL}${PATCHVER_PL}.patch.bz2 )"
fi

S="${WORKDIR}"/prefix-${PN}-${PV}
S_PL="${WORKDIR}"/${PN}-${PV_PL}

portage_docs() {
	elog ""
	elog "For help with using portage please consult the Gentoo Handbook"
	elog "at http://www.gentoo.org/doc/en/handbook/handbook-x86.xml?part=3"
	elog ""
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	if [ -n "${PATCHVER}" ]; then
		cd "${S}"
		epatch "${WORKDIR}/${PN}-${PATCHVER}.patch"
	fi

	if [ -n "${PATCHVER_PL}" ]; then
		use linguas_pl && \
			epatch "${WORKDIR}/${PN}-man-pl-${PV_PL}${PATCHVER_PL}.patch"
	fi
}

src_compile() {
	econf \
		--with-portage-user=${PORTAGE_USER:-portage} \
		--with-portage-group=${PORTAGE_GROUP:-portage} \
		--with-offset-prefix=${EPREFIX} \
		--with-default-path="/usr/bin:/bin" \
		|| die "econf failed"
	emake || die "emake failed"

	if use elibc_FreeBSD; then
		cd "${S}"/src/bsd-flags
		chmod +x setup.py
		./setup.py build || die "Failed to install bsd-chflags module"
	fi

	if use epydoc; then
		einfo "Generating api docs"
		mkdir "${WORKDIR}"/api
		local my_modules
		my_modules="$(find "${S}/pym" -name "*.py" \
			| sed -e 's:.*__init__.py$::' -e 's:\.py$::' -e "s:^${S}/pym/::" \
			 -e 's:/:.:g')" || die "error listing modules"
		PYTHONPATH="${S}/pym:${PYTHONPATH}" epydoc -o "${WORKDIR}"/api \
			-qqqqq --ignore-param-mismatch ${my_modules} || die "epydoc failed"
	fi
}

src_test() {
	./tests/runTests || \
		die "test(s) failed"
}

src_install() {
	make DESTDIR="${D}" install || die "make install failed."
	dodir /usr/lib/portage/bin

	if use elibc_FreeBSD; then
		cd "${S}"/src/bsd-flags
		./setup.py install --root "${ED}" || \
			die "Failed to install bsd-chflags module"
	fi

	if use linguas_pl; then
		doman -i18n=pl "${S_PL}"/man/pl/*.[0-9]
		doman -i18n=pl_PL.UTF-8 "${S_PL}"/man/pl_PL.UTF-8/*.[0-9]
	fi
	dodoc "${S}"/ChangeLog
	dodoc "${S}"/NEWS
	dodoc "${S}"/RELEASE-NOTES
	use epydoc && dohtml -r "${WORKDIR}"/api
	dodir /etc/portage
	dodir /var/lib/portage
	dodir /var/log/portage
	keepdir /etc/portage

	echo PYTHONPATH=\"${portage_base}/pym\" > "${WORKDIR}"/05portage.envd
	doenvd "${WORKDIR}"/05portage.envd
}

pkg_preinst() {
	local portage_base="/usr/$(get_libdir)/portage"
	if has livecvsportage ${FEATURES} && [ "${ROOT}" = "/" ]; then
		rm -rf "${ED}"/${portage_base}/pym/*
		mv "${ED}"/${portage_base}/bin/tbz2tool "${T}"
		rm -rf "${ED}"/${portage_base}/bin/*
		mv "${T}"/tbz2tool "${ED}"/${portage_base}/bin/
	else
		for mydir in bin pym pym/cache pym/elog_modules; do
			rm "${EROOT}"/${portage_base}/${mydir}/*.pyc >& /dev/null
			rm "${EROOT}"/${portage_base}/${mydir}/*.pyo >& /dev/null
		done
	fi
}

pkg_postinst() {
	local x

	if [ ! -f "${EROOT}/var/lib/portage/world" ] &&
	   [ -f ${EROOT}/var/cache/edb/world ] &&
	   [ ! -h ${EROOT}/var/cache/edb/world ]; then
		mv ${EROOT}/var/cache/edb/world ${EROOT}/var/lib/portage/world
		ln -s ../../lib/portage/world ${EROOT}/var/cache/edb/world
	fi

	for x in ${EROOT}/etc/._cfg????_make.globals; do
		# Overwrite the globals file automatically.
		[ -e "${x}" ] && mv -f "${x}" "${EROOT}/etc/make.globals"
	done

	portage_docs
}
