# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/util-linux/util-linux-2.20.1.ebuild,v 1.1 2011/10/20 13:37:01 vapier Exp $

EAPI="3"

EGIT_REPO_URI="git://git.kernel.org/pub/scm/utils/util-linux/util-linux.git"
inherit eutils toolchain-funcs libtool flag-o-matic autotools
[[ ${PV} == "9999" ]] && inherit git autotools

MY_PV=${PV/_/-}
MY_P=${PN}-${MY_PV}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Various useful Linux utilities"
HOMEPAGE="http://www.kernel.org/pub/linux/utils/util-linux/"
if [[ ${PV} == "9999" ]] ; then
	SRC_URI=""
	#KEYWORDS=""
else
	SRC_URI="mirror://kernel/linux/utils/util-linux/v${PV:0:4}/${MY_P}.tar.bz2
		loop-aes? ( http://loop-aes.sourceforge.net/updates/util-linux-2.20-20110905.diff.bz2 )"
	# prefix patches don't apply, but we still need them
	#  -> why would we want util-linux anyway? just for libuuid
	#KEYWORDS="~ppc-macos ~x64-macos ~x86-macos"
fi

LICENSE="GPL-2"
SLOT="0"
IUSE="+cramfs crypt ddate loop-aes ncurses nls old-linux perl selinux slang static-libs uclibc unicode"

RDEPEND="!sys-process/schedutils
	!sys-apps/setarch
	!<sys-apps/sysvinit-2.88-r3
	!<sys-libs/e2fsprogs-libs-1.41.8
	!<sys-fs/e2fsprogs-1.41.8
	cramfs? ( sys-libs/zlib )
	ncurses? ( >=sys-libs/ncurses-5.2-r2 )
	perl? ( dev-lang/perl )
	selinux? ( sys-libs/libselinux )
	slang? ( sys-libs/slang )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )
	virtual/os-headers"

src_prepare() {
	if [[ ${PV} == "9999" ]] ; then
		po/update-potfiles
		autopoint --force
		eautoreconf
	else
		use loop-aes && epatch "${WORKDIR}"/util-linux-*.diff
	fi
	use uclibc && sed -i -e s/versionsort/alphasort/g -e s/strverscmp.h/dirent.h/g mount/lomount.c
	elibtoolize
}

lfs_fallocate_test() {
	# Make sure we can use fallocate with LFS #300307
	cat <<-EOF > "${T}"/fallocate.c
	#define _GNU_SOURCE
	#include <fcntl.h>
	main() { return fallocate(0, 0, 0, 0); }
	EOF
	append-lfs-flags
	$(tc-getCC) ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} "${T}"/fallocate.c -o /dev/null >/dev/null 2>&1 \
		|| export ac_cv_func_fallocate=no
	rm -f "${T}"/fallocate.c
}

want_libuuid() {
	# bug #350841, currently only not on OS X Snow Leopard and onwards
	[[ ${CHOST} != *-darwin1[0123] ]]
}

usex() { use $1 && echo ${2:-yes} || echo ${3:-no} ; }
src_configure() {
	lfs_fallocate_test
	local myconf=
	if use prefix ; then
		myconf="
			--with-ncurses=$(usex ncurses $(usex unicode auto yes) no) \
			--disable-mount
			--disable-fsck
			--$($(want_libuuid) && echo enable || echo disable)-libuuid
			--disable-uuidd
			--enable-libblkid
			--disable-arch
			--disable-agetty
			--disable-cramfs
			--disable-switch_root
			--disable-pivot_root
			--disable-fallocate
			--disable-unshare
			--disable-elvtune
			--disable-init
			--disable-kill
			--disable-last
			--disable-mesg
			--disable-partx
			--disable-raw
			--disable-rename
			--disable-reset
			--disable-login-utils
			--disable-schedutils
			--disable-wall
			--disable-write
			--disable-login-chown-vcs
			--disable-login-stat-mail
			--disable-pg-bell
			--disable-use-tty-group
			--disable-makeinstall-chown
			--disable-makeinstall-setuid
		"
	else
		myconf="
			--enable-agetty
			$(use_enable cramfs)
			$(use_enable ddate) \
			$(use_enable old-linux elvtune)
			--with-ncurses=$(usex ncurses $(usex unicode auto yes) no) \
			--disable-kill
			--disable-last
			--disable-mesg
			--enable-partx
			--enable-raw
			--enable-rename
			--disable-reset
			--disable-login-utils
			--enable-schedutils
			--disable-wall
			--enable-write
			--without-pam
			$(use_with selinux)
		"
	fi

	#	--with-fsprobe=blkid \
	econf \
		--enable-fs-paths-extra="${EPREFIX}"/usr/sbin \
		$(use_enable nls) \
		$(use_with slang) \
		$(use_enable static-libs static) \
		$(tc-has-tls || echo --disable-tls) \
		${myconf}
}

src_compile() {
	if use prefix; then
		emake -C shlibs || die
	else
		emake || die
	fi
}

src_install() {
	if use prefix ; then
		emake -C shlibs install DESTDIR="${D}" || die "install failed"
	else
		emake install DESTDIR="${D}" || die "install failed"

		if ! use perl ; then #284093
			rm "${ED}"/usr/bin/chkdupexe || die
			rm "${ED}"/usr/share/man/man1/chkdupexe.1 || die
		fi

		if use crypt ; then
			newinitd "${FILESDIR}"/crypto-loop.initd crypto-loop || die
			newconfd "${FILESDIR}"/crypto-loop.confd crypto-loop || die
		fi
	fi
	dodoc AUTHORS NEWS README* TODO docs/*
	use ddate || find "${ED}"/usr/share/man -name 'ddate.1*' -delete

	# need the libs in /
	local libuuid=
	$(want_libuuid) && libuuid=uuid
	gen_usr_ldscript -a blkid ${libuuid}
	# e2fsprogs-libs didnt install .la files, and .pc work fine
	rm -f "${ED}"/usr/$(get_libdir)/*.la
}

pkg_postinst() {
	ewarn "The loop-aes code has been split out of USE=crypt and into USE=loop-aes."
	ewarn "If you need support for it, make sure to update your USE accordingly."
}

pkg_postinst() {
	elog "The agetty util now clears the terminal by default.  You"
	elog "might want to add --noclear to your /etc/inittab lines."
}
