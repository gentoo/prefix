# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/e2fsprogs-libs/e2fsprogs-libs-1.41.7.ebuild,v 1.7 2012/06/11 19:38:50 vapier Exp $

EAPI=2

inherit flag-o-matic toolchain-funcs eutils multilib

DESCRIPTION="e2fsprogs libraries (common error, subsystem, uuid, block id)"
HOMEPAGE="http://e2fsprogs.sourceforge.net/"
SRC_URI="mirror://sourceforge/e2fsprogs/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint"
IUSE="nls"

RDEPEND="!sys-libs/com_err
	!sys-libs/ss
	!<sys-fs/e2fsprogs-1.41"
DEPEND="nls? ( sys-devel/gettext )
	virtual/pkgconfig"

src_prepare() {
	# stupid configure script clobbers CC for us
	sed -i '/if test -z "$CC" ; then CC=cc; fi/d' configure
	epatch "${FILESDIR}"/${PN}-1.41.12-darwin-makefile.patch
	epatch "${FILESDIR}"/${PN}-1.41.9-irix.patch
	if [[ ${CHOST} == *-mint* ]]; then
		sed -i -e 's/_SVID_SOURCE/_GNU_SOURCE/' lib/uuid/gen_uuid.c || die
	fi
}

src_configure() {
	# We want to use the "bsd" libraries while building on Darwin, but while
	# building on other Gentoo/*BSD we prefer elf-naming scheme.
	local libtype
	case ${CHOST} in
		*-darwin*) libtype=--enable-bsd-shlibs  ;;
		*-mint*)   libtype=                     ;;
		*)         libtype=--enable-elf-shlibs  ;;
	esac

	# avoid a problem during parallel make, it bails because it creates the pic
	# directory too late
	mkdir ./lib/blkid/pic ./lib/et/pic ./lib/ss/pic ./lib/uuid/pic 

	ac_cv_path_LDCONFIG=: \
	econf \
		${libtype} \
		$(tc-has-tls || echo --disable-tls) \
		$(use_enable nls)
}

src_install() {
	emake STRIP=: DESTDIR="${D}" install || die

	set -- "${ED}"/usr/$(get_libdir)/*.a
	set -- ${@/*\/lib}
	gen_usr_ldscript -a "${@/.a}"
}
