# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PATCHVER="3"
ELF2FLT_VER=""
inherit toolchain-binutils

KEYWORDS="~x64-cygwin ~amd64-linux ~x86-linux ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

PATCHES=(
	"${FILESDIR}/${P}-nogoldtest.patch"
	"${FILESDIR}"/${PN}-2.22-solaris-anonymous-version-script-fix.patch
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
