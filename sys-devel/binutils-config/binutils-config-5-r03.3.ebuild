# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit eutils prefix

DESCRIPTION="Utility to change the binutils version being used"
HOMEPAGE="https://www.gentoo.org/"
GIT_REV="b93602ba2a0f76a9a85cb36a1740a4522e45ce36"
WRAPPER_REV="${PV}.3.3"
SRC_URI="https://gitweb.gentoo.org/repo/proj/prefix.git/plain/sys-devel/binutils-config/files/ldwrapper.c?id=${GIT_REV} -> ${PN}-ldwrapper-${WRAPPER_REV}.c"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""

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
	eapply_user
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
		-o ldwrapper "${DISTDIR}"/${PN}-ldwrapper-${WRAPPER_REV}.c
		-DEPREFIX=\"${EPREFIX}\"
		-DCHOST=\"${CHOST}\"
		${LDFLAGS}
	)
	echo ${args[*]}
	"${args[@]}" || die
}

src_install() {
	dobin ${PN}
	use prefix && eprefixify "${ED}"/usr/bin/${PN}
	sed -i "s:@PV@:${PVR}:g" "${ED}"/usr/bin/${PN} || die
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
