# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5

inherit eutils prefix

DESCRIPTION="Utility to change the binutils version being used"
HOMEPAGE="https://www.gentoo.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

# We also RDEPEND on sys-apps/findutils which is in base @system
RDEPEND="sys-apps/gentoo-functions
	!<app-admin/eselect-1.4.5"

S=${WORKDIR}

# NOTE: the ld wrapper is only enabled on rpath versions of prefix.
src_prepare() {
	cp "${FILESDIR}"/${PN}-${PV} ./${PN} || die
	if use prefix-guest; then
		epatch "${FILESDIR}/${PN}-5-ldwrapper.patch"
	fi
	eprefixify ${PN}

	cp "${FILESDIR}"/ldwrapper.c . || die
}

src_configure() {
	:
}

src_compile() {
	use prefix-guest || return
	local args=(
		$(tc-getCC)
		${CPPFLAGS}
		${CFLAGS}
		-o ldwrapper ldwrapper.c
		-DEPREFIX=\"${EPREFIX}\"
		-DCHOST=\"${CHOST}\"
		$([[ ${CHOST} == *-darwin* ]] && echo -DTARGET_DARWIN)
		${LDFLAGS}
	)
	echo ${args[*]}
	"${args[@]}" || die
}

src_install() {
	newbin "${S}"/${PN} ${PN}
	doman "${FILESDIR}"/${PN}.8

	dodir /usr/$(get_libdir)/misc/binutils-config
	mv "${S}"/ldwrapper "${ED}"/usr/$(get_libdir)/misc/binutils-config/

	insinto /usr/share/eselect/modules
	doins "${FILESDIR}"/binutils.eselect
}

pkg_preinst() {
	# Force a refresh when upgrading from an older version that symlinked
	# in all the libs & includes that binutils-libs handles. #528088
	if has_version "<${CATEGORY}/${PN}-5" ; then
		local bc current
		bc="${ED}/usr/bin/binutils-config"
		if current=$("${bc}" -c) ; then
			"${bc}" "${current}"
		fi
	fi
}

pkg_postinst() {
	# refresh all links and the wrapper
	if [[ ${ROOT%/} == "" ]] ; then
		[[ -f ${EROOT}/etc/env.d/binutils/config-${CHOST} ]] \
			&& binutils-config $(binutils-config --get-current-profile)
	fi
}
