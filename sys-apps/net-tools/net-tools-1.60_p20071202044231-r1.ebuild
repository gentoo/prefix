# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/net-tools/net-tools-1.60_p20071202044231-r1.ebuild,v 1.2 2008/05/10 07:26:33 vapier Exp $

EAPI="prefix"

inherit flag-o-matic toolchain-funcs eutils

DESCRIPTION="Standard Linux networking tools"
HOMEPAGE="http://net-tools.berlios.de/"
SRC_URI="mirror://gentoo/${P}.tar.lzma"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="nls static"

RDEPEND=""
DEPEND="nls? ( sys-devel/gettext )
	app-arch/lzma-utils"

maint_pkg_create() {
	cd /usr/local/src/net-tools
	#git-update
	local stamp=$(git log -n1 --pretty=format:%ai | sed -e 's:[- :]::g' -e 's:+.*::')
	local pv="${PV/_p*}_p${stamp}"
	local p="${PN}-${pv}"
	git-archive --prefix="${p}/" HEAD | lzma > "${T}"/${p}.tar.lzma
	du -b "${T}"/${p}.tar.lzma
}

pkg_setup() { [[ -n ${VAPIER_LOVES_YOU} ]] && maint_pkg_create ; }

src_unpack() {
	unpack ${A}
	cd "${S}"
	EPATCH_SUFFIX="patch" EPATCH_FORCE="yes" epatch "${FILESDIR}"/${PV}/

	sed -i "/^bool.*I18N/s:[yn]$:$(use nls && echo y || echo n):" config.in
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
