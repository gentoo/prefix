# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/net-tools/net-tools-1.60_p20090728014017-r1.ebuild,v 1.9 2010/03/11 23:06:27 tcunha Exp $

inherit flag-o-matic toolchain-funcs eutils

PATCH_VER="3"
DESCRIPTION="Standard Linux networking tools"
HOMEPAGE="http://net-tools.berlios.de/"
SRC_URI="mirror://gentoo/${P}.tar.lzma
	mirror://gentoo/${P}-patches-${PATCH_VER}.tar.lzma"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="nls static"

RDEPEND=""
DEPEND="nls? ( sys-devel/gettext )
	|| ( app-arch/xz-utils app-arch/lzma-utils )"

maint_pkg_create() {
	cd /usr/local/src/net-tools
	#git-update
	local stamp=$(git log -n1 --pretty=format:%ai master | sed -e 's:[- :]::g' -e 's:+.*::')
	local pv="${PV/_p*}_p${stamp}"
	local p="${PN}-${pv}"
	git archive --prefix="${p}/" master | lzma > "${T}"/${p}.tar.lzma

	local patches="${p}-patches-${PATCH_VER}"
	mkdir "${T}"/${patches}
	git format-patch -o "${T}"/${patches} master..gentoo > /dev/null
	tar cf - -C "${T}" ${patches} | lzma > "${T}"/${patches}.tar.lzma

	du -b "${T}"/*.tar.lzma
}

pkg_setup() { [[ -n ${VAPIER_LOVES_YOU} ]] && maint_pkg_create ; }

set_opt() {
	local opt=$1 ans
	shift
	ans=$("$@" && echo y || echo n)
	einfo "Setting option ${opt} to ${ans}"
	sed -i \
		-e "/^bool.* ${opt} /s:[yn]$:${ans}:" \
		config.in || die
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	EPATCH_SUFFIX="patch" EPATCH_FORCE="yes" epatch "${WORKDIR}"/${P}-patches-${PATCH_VER}

	set_opt I18N use nls
	set_opt HAVE_HWIB has_version '>=sys-kernel/linux-headers-2.6'
	if use static ; then
		append-flags -static
		append-ldflags -static
	fi
}

src_compile() {
	tc-export AR CC
	yes "" | ./configure.sh config.in || die
	emake libdir || die
	emake || die
	if use nls ; then
		emake i18ndir || die "emake i18ndir failed"
	fi
}

src_install() {
	emake BASEDIR="${ED}" install || die "make install failed"
	dodoc README README.ipv6 TODO
}

pkg_postinst() {
	einfo "etherwake and such have been split into net-misc/ethercard-diag"
}
