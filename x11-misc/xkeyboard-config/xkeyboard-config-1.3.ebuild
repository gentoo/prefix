# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-misc/xkeyboard-config/xkeyboard-config-1.3.ebuild,v 1.3 2009/05/05 17:41:19 ssuominen Exp $

inherit eutils multilib

DESCRIPTION="X keyboard configuration database"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/XKeyboardConfig"
SRC_URI="http://xlibs.freedesktop.org/xkbdesc/${P}.tar.bz2"

LICENSE="MIT"
SLOT="0"
IUSE=""

RDEPEND="x11-apps/xkbcomp
	!x11-misc/xkbdata"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.30
	dev-perl/XML-Parser"

pkg_setup() {
	# (#130590) The old XKB directory can screw stuff up
	local DIR="${EROOT}usr/$(get_libdir)/X11/xkb"
	if [[ -d ${DIR} ]] ; then
		eerror "Directory ${DIR} should be"
		eerror "manually deleted/renamed/relocated before installing!"
		die "Manually remove ${DIR}"
	fi

	# The old xkbdata 'pc' directory can screw stuff up, because portage won't
	# let us overwrite a directory with a file
	local PC="${EROOT}usr/share/X11/xkb/symbols/pc"
	if [[ -d ${PC} ]] ; then
		eerror "Directory ${PC} should be"
		eerror "manually deleted/renamed/relocated before installing!"
		die "Manually remove ${PC}"
	fi
}

src_compile() {
	econf \
		--with-xkb-base=${EROOT}/usr/share/X11/xkb \
		--enable-compat-rules \
		--disable-xkbcomp-symlink \
		--with-xkb-rules-symlink=xorg \
		|| die "configure failed"

	emake || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "install failed"
}
