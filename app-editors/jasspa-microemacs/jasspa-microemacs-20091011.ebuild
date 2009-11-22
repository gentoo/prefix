# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/jasspa-microemacs/jasspa-microemacs-20091011.ebuild,v 1.3 2009/11/21 18:58:04 nixnut Exp $

inherit eutils toolchain-funcs

DESCRIPTION="Jasspa Microemacs"
HOMEPAGE="http://www.jasspa.com/"
SRC_URI="http://www.jasspa.com/release_20090909/jasspa-mesrc-${PV}.tar.gz
	!nanoemacs? (
		http://www.jasspa.com/release_20090909/jasspa-memacros-${PV}.tar.gz
		http://www.jasspa.com/release_20090909/jasspa-mehtml-${PV}.tar.gz
		http://www.jasspa.com/release_20060909/meicons-extra.tar.gz )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"
IUSE="nanoemacs X xpm"

RDEPEND="sys-libs/ncurses
	X? ( x11-libs/libX11
		xpm? ( x11-libs/libXpm ) )
	nanoemacs? ( !app-editors/ne )"

DEPEND="${RDEPEND}
	X? ( x11-libs/libXt
		x11-proto/xproto )"

S="${WORKDIR}/me${PV:2}/src"

src_unpack() {
	unpack jasspa-mesrc-${PV}.tar.gz
	if ! use nanoemacs; then
		mkdir "${WORKDIR}/jasspa"
		cd "${WORKDIR}/jasspa"
		# everything except jasspa-mesrc
		unpack ${A/jasspa-mesrc-${PV}.tar.gz/}
	fi
	cd "${S}"
	epatch "${FILESDIR}/${PV}-ncurses.patch"

	# allow for some variables to be passed to make
	sed -i '/make/s/\$OPTIONS/& CC="$CC" COPTIMISE="$CFLAGS" STRIP=true/' \
		build || die "sed failed"
}

src_compile() {
	local loadpath="~/.jasspa:${EPREFIX}/usr/share/jasspa/site:${EPREFIX}/usr/share/jasspa"
	local me="" type=c
	use nanoemacs && me="-ne"
	use X && type=cw
	use xpm || export XPM_INCLUDE=.		# prevent Xpm autodetection

	CC="$(tc-getCC)" ./build ${me} -t ${type} -p "${loadpath}" \
		|| die "build failed"
}

src_install() {
	local me=me type=c
	use nanoemacs && me=ne
	use X && type=cw
	newbin ${me}${type} ${me} || die "newbin failed"

	if ! use nanoemacs; then
		keepdir /usr/share/jasspa/site
		insinto /usr/share
		doins -r "${WORKDIR}/jasspa"
		if use X; then
			insinto /usr/share/applications
			doins "${FILESDIR}/${PN}.desktop"
		fi
	fi

	dodoc ../faq.txt ../readme.txt ../change.log || die "dodoc failed"
}
