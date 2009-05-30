# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-libs/e2fsprogs-libs/e2fsprogs-libs-1.41.5.ebuild,v 1.1 2009/05/29 23:26:49 vapier Exp $

EAPI=2

inherit flag-o-matic toolchain-funcs

DESCRIPTION="e2fsprogs libraries (common error, subsystem, uuid, block id)"
HOMEPAGE="http://e2fsprogs.sourceforge.net/"
SRC_URI="mirror://sourceforge/e2fsprogs/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos"
IUSE="nls"

RDEPEND="elibc_glibc? ( !prefix? ( >=sys-libs/glibc-2.6 ) )
	!sys-libs/com_err
	!sys-libs/ss
	!<sys-fs/e2fsprogs-1.41"
DEPEND="nls? ( sys-devel/gettext )
	sys-devel/bc"

src_prepare() {
	# stupid configure script clobbers CC for us
	sed -i '/if test -z "$CC" ; then CC=cc; fi/d' configure

	epatch "${FILESDIR}"/${PN}-1.41.1-darwin-makefile.patch
}

src_configure() {
	# We want to use the "bsd" libraries while building on Darwin, but while
	# building on other Gentoo/*BSD we prefer elf-naming scheme.
	local libtype
	case ${CHOST} in
		*-darwin*) libtype=bsd;;
		*)         libtype=elf;;
	esac

	# avoid a problem during parallel make, it bails because it creates the pic
	# directory too late
	mkdir ./lib/blkid/pic ./lib/et/pic ./lib/ss/pic ./lib/uuid/pic 

	ac_cv_path_LDCONFIG=: \
	econf \
		--enable-${libtype}-shlibs \
		$(use_enable !elibc_uclibc tls) \
		$(use_enable nls)
}

src_install() {
	emake STRIP=: DESTDIR="${D}" install || die

	set -- "${ED}"/usr/$(get_libdir)/*.a
	set -- ${@/*\/lib}
	gen_usr_ldscript -a "${@/.a}"
}
