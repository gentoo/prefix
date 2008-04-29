# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/mc/mc-4.6.2_pre1.ebuild,v 1.3 2008/04/28 13:21:25 drac Exp $

EAPI="prefix"

inherit eutils

MY_P=${P/_/-}

DESCRIPTION="GNU Midnight Commander is a s-lang based file manager."
HOMEPAGE="http://www.gnu.org/software/mc"
SRC_URI="http://ftp.gnu.org/gnu/mc/${MY_P}.tar.gz
	http://dev.gentoo.org/~drac/${MY_P}-patches-1.tbz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE="gpm nls samba X"

RDEPEND=">=dev-libs/glib-2
	>=sys-libs/slang-2.1.3
	gpm? ( sys-libs/gpm )
	X? ( x11-libs/libX11
		x11-libs/libICE
		x11-libs/libXau
		x11-libs/libXdmcp
		x11-libs/libSM )
	samba? ( net-fs/samba )
	kernel_linux? ( sys-fs/e2fsprogs )
	app-arch/zip
	app-arch/unzip"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	dev-util/pkgconfig"

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${A}
	cd "${S}"
	EPATCH_SUFFIX="patch" epatch "${WORKDIR}"/patches

	# Prevent lazy bindings in cons.saver binary for bug #135009
	sed -i -e "s:^\(cons_saver_LDADD = .*\):\1 -Wl,-z,now:" \
		src/Makefile.in || die "sed failed."
}

src_compile() {
	# Default is slang for unicode in Gentoo (which is also upstream default)
	local myconf="--with-vfs --with-ext2undel --with-edit --enable-charset --with-screen=slang"

	if use samba; then
		myconf+=" --with-samba --with-configdir=${EPREFIX}/etc/samba --with-codepagedir=${EPREFIX}/var/lib/samba/codepages"
	else
		myconf+=" --without-samba"
	fi

	econf --disable-dependency-tracking \
		$(use_enable nls) \
		$(use_with gpm gpm-mouse) \
		$(use_with X x) \
		${myconf}

	emake || die "emake failed."
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed."
	dodoc AUTHORS FAQ HACKING MAINTAINERS NEWS README* TODO

	# Install cons.saver setuid to actually work
	fperms u+s /usr/libexec/mc/cons.saver

	# Install ebuild syntax
	insinto /usr/share/mc/syntax
	doins "${FILESDIR}"/ebuild.syntax
}
