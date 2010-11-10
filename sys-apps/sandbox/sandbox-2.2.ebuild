# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/sandbox/sandbox-2.2.ebuild,v 1.3 2010/08/15 05:22:23 vapier Exp $

#
# don't monkey with this ebuild unless contacting portage devs.
# period.
#

inherit eutils flag-o-matic toolchain-funcs multilib prefix

DESCRIPTION="sandbox'd LD_PRELOAD hack"
HOMEPAGE="http://www.gentoo.org/"
SRC_URI="mirror://gentoo/${P}.tar.lzma
	http://dev.gentoo.org/~vapier/dist/${P}.tar.lzma"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~ia64-linux ~x86-linux"
IUSE="multilib"

DEPEND="app-arch/xz-utils
	>=app-misc/pax-utils-0.1.19" #265376
RDEPEND=""

EMULTILIB_PKG="true"
has sandbox_death_notice ${EBUILD_DEATH_HOOKS} || EBUILD_DEATH_HOOKS="${EBUILD_DEATH_HOOKS} sandbox_death_notice"

sandbox_death_notice() {
	ewarn "If configure failed with a 'cannot run C compiled programs' error, try this:"
	ewarn "FEATURES=-sandbox emerge sandbox"
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PN}-2.0-prefix.patch
	eprefixify etc/sandbox.d/00default
}

sb_get_install_abis() { use multilib && get_install_abis || echo ${ABI:-default} ; }

src_unpack() {
	unpack ${A}
	if [[ ! -d ${S} ]] ; then
		# When upgrading from older version, lzma unpack may not work #271543
		lzma -dc "${DISTDIR}/${A}" | tar xf - || die
	fi
}

src_compile() {
	filter-lfs-flags #90228

	# enable usage of absolute libpath in prefix
	use prefix && append-flags -DGENTOO_PREFIX

	local OABI=${ABI}
	for ABI in $(sb_get_install_abis) ; do
		mkdir "${WORKDIR}/build-${ABI}"
		cd "${WORKDIR}/build-${ABI}"

		use multilib && multilib_toolchain_setup ${ABI}

		einfo "Configuring sandbox for ABI=${ABI}..."
		ECONF_SOURCE="../${P}/" \
		econf ${myconf} || die
		einfo "Building sandbox for ABI=${ABI}..."
		emake || die
	done
	ABI=${OABI}
}

src_test() {
	local OABI=${ABI}
	for ABI in $(sb_get_install_abis) ; do
		cd "${WORKDIR}/build-${ABI}"
		einfo "Checking sandbox for ABI=${ABI}..."
		emake check || die "make check failed for ${ABI}"
	done
	ABI=${OABI}
}

src_install() {
	local OABI=${ABI}
	for ABI in $(sb_get_install_abis) ; do
		cd "${WORKDIR}/build-${ABI}"
		einfo "Installing sandbox for ABI=${ABI}..."
		emake DESTDIR="${D}" install || die "make install failed for ${ABI}"
	done
	ABI=${OABI}

	doenvd "${FILESDIR}"/09sandbox

	keepdir /var/log/sandbox
	use prefix || fowners root:portage /var/log/sandbox
	fperms 0770 /var/log/sandbox

	cd "${S}"
	dodoc AUTHORS ChangeLog* NEWS README
}

pkg_preinst() {
	use prefix || chown root:portage "${ED}"/var/log/sandbox
	chmod 0770 "${ED}"/var/log/sandbox

	local old=$(find "${EROOT}"/lib* -maxdepth 1 -name 'libsandbox*')
	if [[ -n ${old} ]] ; then
		elog "Removing old sandbox libraries for you:"
		elog ${old//${EROOT}}
		find "${EROOT}"/lib* -maxdepth 1 -name 'libsandbox*' -exec rm -fv {} \;
	fi
}

pkg_postinst() {
	chmod 0755 "${EROOT}"/etc/sandbox.d #265376
}
