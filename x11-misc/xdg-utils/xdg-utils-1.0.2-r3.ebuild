# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xdg-utils/xdg-utils-1.0.2-r3.ebuild,v 1.5 2009/06/01 14:19:52 gentoofan23 Exp $

inherit eutils

DESCRIPTION="Portland utils for cross-platform/cross-toolkit/cross-desktop interoperability"
HOMEPAGE="http://portland.freedesktop.org/wiki"
SRC_URI="http://portland.freedesktop.org/download/${P}.tgz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="doc"

# Report ?, some tests need root access
RESTRICT="test"

RDEPEND="x11-apps/xprop
	x11-misc/shared-mime-info
	x11-apps/xset"
PDEPEND="dev-util/desktop-file-utils"
DEPEND="app-text/xmlto"

src_unpack() {
	unpack ${A}
	cd "${S}"/scripts
	epatch "${FILESDIR}"/${P}-arb-comm-exec.patch \
		"${FILESDIR}"/${P}-kdedirs.patch \
		"${FILESDIR}"/${P}-xdgopen-kde.patch
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc ChangeLog README RELEASE_NOTES TODO || die "dodoc failed."
	newdoc scripts/README README.scripts || die "newdoc failed."

	if use doc; then
		dohtml -r scripts/html || die "dohtml failed."
	fi

	# Install default XDG_DATA_DIRS, bug #264647
	echo 'XDG_DATA_DIRS="/usr/local/share"' > 30xdg-data-local
	echo 'COLON_SEPARATED="XDG_DATA_DIRS XDG_CONFIG_DIRS"' >> 30xdg-data-local
	doenvd 30xdg-data-local || die "doenv failed"

	echo 'XDG_DATA_DIRS="/usr/share"' > 90xdg-data-base
	echo 'XDG_CONFIG_DIRS="/etc/xdg"' >> 90xdg-data-base
	doenvd 90xdg-data-base || die "doenv failed"
}

pkg_postinst() {
	elog "Install >=x11-libs/gtk+-2 if you need command gtk-update-icon-cache."
}
