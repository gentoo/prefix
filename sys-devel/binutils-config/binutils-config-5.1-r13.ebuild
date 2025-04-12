# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs prefix

DESCRIPTION="Utility to change the binutils version being used"
HOMEPAGE="https://www.gentoo.org/"
WRAPPER_REV="${PV%%.*}.3.4"
#SRC_URI="https://gitweb.gentoo.org/repo/proj/prefix.git/plain/sys-devel/binutils-config/files/ldwrapper.c?id=${GIT_REV} -> ${PN}-ldwrapper-${WRAPPER_REV}.c"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~x64-solaris"
IUSE=""

# We also RDEPEND on sys-apps/findutils which is in base @system
RDEPEND="sys-apps/gentoo-functions
	!<app-admin/eselect-1.4.5"

S=${WORKDIR}

# NOTE: the ld wrapper is only enabled on rpath versions of prefix.
src_prepare() {
	cp "${FILESDIR}"/${PN}-${PV} ./${PN} || die
	cp "${FILESDIR}"/ldwrapper.c ./${PN}-ldwrapper-${WRAPPER_REV}.c || die
	if use prefix-guest; then
		eapply "${FILESDIR}/${PN}-5-ldwrapper.patch" || die
	fi
	eprefixify ${PN}
	eapply_user
}

src_configure() {
	:
}

src_compile() {
	use prefix-guest || return
	local extraargs=( )
	if [[ ${CHOST} == *-darwin* ]] ; then
		extraargs+=(
			-DDARWIN_LD_DEFAULT_TARGET='"'${MACOSX_DEPLOYMENT_TARGET}'"'
		)
	fi
	local args=(
		$(tc-getCC)
		${CPPFLAGS}
		${CFLAGS}
		-Wall
		-o ldwrapper ${PN}-ldwrapper-${WRAPPER_REV}.c
		-DEPREFIX=\"${EPREFIX}\"
		-DCHOST=\"${CHOST}\"
		"${extraargs[@]}"
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
