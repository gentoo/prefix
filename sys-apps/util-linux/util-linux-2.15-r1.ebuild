# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/util-linux/util-linux-2.15-r1.ebuild,v 1.2 2009/05/24 18:38:00 vapier Exp $

EGIT_REPO_URI="git://git.kernel.org/pub/scm/utils/util-linux-ng/util-linux-ng.git"
inherit eutils autotools
[[ ${PV} == "9999" ]] && inherit git autotools

MY_PV=${PV/_/-}
MY_P=${PN}-ng-${MY_PV}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Various useful Linux utilities"
HOMEPAGE="http://www.kernel.org/pub/linux/utils/util-linux-ng/"
if [[ ${PV} == "9999" ]] ; then
	SRC_URI=""
else
	SRC_URI="mirror://kernel/linux/utils/util-linux-ng/v${PV:0:4}/${MY_P}.tar.bz2
		loop-aes? ( http://loop-aes.sourceforge.net/updates/util-linux-ng-2.15-20090511.diff.bz2 )"
fi

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux"
IUSE="crypt loop-aes nls old-linux selinux slang uclibc unicode"

RDEPEND="!sys-process/schedutils
	!sys-apps/setarch
	>=sys-libs/ncurses-5.2-r2
	>=sys-libs/e2fsprogs-libs-1.41
	selinux? ( sys-libs/libselinux )
	slang? ( sys-libs/slang )"
DEPEND="${RDEPEND}
	>=sys-devel/libtool-2
	nls? ( sys-devel/gettext )
	virtual/os-headers"

src_unpack() {
	if [[ ${PV} == "9999" ]] ; then
		git_src_unpack
		cd "${S}"
		eautoreconf
	else
		unpack ${A}
		cd "${S}"
		#epatch "${FILESDIR}"/${PN}-2.13-uclibc.patch #203711
		epatch "${FILESDIR}"/${P}-cpuid-pic.patch #269001
		if use loop-aes ; then
			epatch "${WORKDIR}"/util-linux-ng-*.diff
		else
			epatch "${FILESDIR}"/${P}-losetup-symlinks.patch #269264
		fi
		epatch "${FILESDIR}"/${P}-old-libselinux.patch #270168
		eautoreconf
	fi
	use uclibc && sed -i -e s/versionsort/alphasort/g -e s/strverscmp.h/dirent.h/g mount/lomount.c
	use prefix && sed -i -e 's/chgrp tty/#chgrp tty/' misc-utils/Makefile.in || die
}

src_compile() {
	econf \
		--with-fsprobe=blkid \
		$(use_enable nls) \
		--enable-agetty \
		--enable-cramfs \
		$(use_enable old-linux elvtune) \
		--disable-init \
		--disable-kill \
		--disable-last \
		--disable-mesg \
		--enable-partx \
		--enable-raw \
		--enable-rdev \
		--enable-rename \
		--disable-reset \
		--disable-login-utils \
		--enable-schedutils \
		--disable-wall \
		--enable-write \
		--without-pam \
		$(use unicode || echo --with-ncurses) \
		$(use_with selinux) \
		$(use_with slang) \
		|| die "configure failed"
	emake || die "emake failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "install failed"
	dodoc AUTHORS NEWS README* TODO docs/*

	if use crypt ; then
		newinitd "${FILESDIR}"/crypto-loop.initd crypto-loop || die
		newconfd "${FILESDIR}"/crypto-loop.confd crypto-loop || die
	fi
}

pkg_postinst() {
	ewarn "The loop-aes code has been split out of USE=crypt and into USE=loop-aes."
	ewarn "If you need support for it, make sure to update your USE accordingly."
	use prefix && ewarn "Be warned that this package is modified to not do:
	'chgrp tty ${EPREFIX}/usr/bin/write' "
	use prefix && ewarn "breakage may occur."
}
