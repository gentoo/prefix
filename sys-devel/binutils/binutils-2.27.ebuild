# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PATCHVER="1.0"
ELF2FLT_VER=""
inherit toolchain-binutils

KEYWORDS="~amd64-linux ~x86-linux ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

PATCHES=(
#	"${FILESDIR}"/${PN}-2.22-mint.patch
#	"${FILESDIR}"/${PN}-2.19.50.0.1-mint.patch
	"${FILESDIR}"/${PN}-2.24-cygwin-nointl.patch
)
pkg_setup() {
	[[ ${CHOST} == *-mint* ]] && die "mint patches require rebasing to ${P}" # 609274
}

src_compile() {
	if has noinfo "${FEATURES}" \
	|| ! type -p makeinfo >/dev/null
	then
		# binutils >= 2.17 (accidentally?) requires 'makeinfo'
		export EXTRA_EMAKE="MAKEINFO=true"
	fi

	toolchain-binutils_src_compile
}
