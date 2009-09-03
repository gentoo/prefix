# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/mc/mc-4.7.0_pre1.ebuild,v 1.15 2009/09/01 14:43:46 jer Exp $

EAPI=2
inherit autotools eutils

MY_P=${P/_/-}

DESCRIPTION="GNU Midnight Commander is a text based file manager"
HOMEPAGE="http://www.midnight-commander.org"
SRC_URI="http://www.midnight-commander.org/downloads/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x86-solaris"
IUSE="chdir gpm nls samba +slang X"

RDEPEND=">=dev-libs/glib-2.6:2
	gpm? ( sys-libs/gpm )
	kernel_linux? ( sys-fs/e2fsprogs )
	samba? ( net-fs/samba )
	slang? ( >=sys-libs/slang-2 )
	!slang? ( sys-libs/ncurses )
	X? ( x11-libs/libX11
		x11-libs/libICE
		x11-libs/libXau
		x11-libs/libXdmcp
		x11-libs/libSM )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	nls? ( sys-devel/gettext )"

S=${WORKDIR}/${MY_P}

src_prepare() {
	rm -f m4/{libtool,lt*}.m4 || die "libtool fix failed"
	epatch "${FILESDIR}"/${P}-ebuild_syntax.patch \
		"${FILESDIR}"/${P}-tbz2_filetype.patch \
		"${FILESDIR}"/${P}-undelfs_configure.patch
	AT_NO_RECURSIVE="yes" eautoreconf
}

src_configure() {
	local myscreen=ncurses

	use slang && myscreen=slang

	econf \
		--disable-dependency-tracking \
		$(use_enable nls) \
		--enable-vfs \
		$(use_enable kernel_linux vfs-undelfs) \
		--enable-charset \
		$(use_with X x) \
		$(use_with samba) \
		--with-configdir="${EPREFIX}"/etc/samba \
		--with-codepagedir="${EPREFIX}"/var/lib/samba/codepages \
		$(use_with gpm gpm-mouse) \
		--with-screen=${myscreen} \
		--with-edit
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	dodoc AUTHORS NEWS README

	if use chdir; then
		insinto /etc/profile.d
		doins "${FILESDIR}"/mc-chdir.sh
	fi
}
