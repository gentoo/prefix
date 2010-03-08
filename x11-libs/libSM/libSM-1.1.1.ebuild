# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libSM/libSM-1.1.1.ebuild,v 1.11 2009/12/15 19:32:55 ranger Exp $

# Must be before x-modular eclass is inherited
#SNAPSHOT="yes"

EAPI="2"

inherit x-modular

DESCRIPTION="X.Org SM library"

KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE="ipv6 +uuid elibc_FreeBSD"

RDEPEND=">=x11-libs/libICE-1.0.5
	x11-libs/xtrans
	x11-proto/xproto
	uuid? (
	  !elibc_FreeBSD? (
	  !elibc_IRIX? (
	  !elibc_SunOS? (
		|| ( >=sys-apps/util-linux-2.16 <sys-libs/e2fsprogs-libs-1.41.8 )
	  ) ) )
	)"
DEPEND="${RDEPEND}"

pkg_setup() {
	CONFIGURE_OPTIONS="$(use_enable ipv6) $(use_with uuid libuuid)"
	# do not use uuid even if available in libc (like on FreeBSD)
	use uuid || export ac_cv_func_uuid_create=no
	if use uuid &&
	   [[ ${CHOST} == *-solaris* ]] &&
	   [[ ! -d ${EROOT}/usr/include/uuid ]] &&
	   [[ -d ${ROOT}/usr/include/uuid ]]
	then
		export LIBUUID_CFLAGS="-I${ROOT}/usr/include/uuid"
		export LIBUUID_LIBS="-luuid"
	fi
}
