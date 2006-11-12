# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/libintl/libintl-0.ebuild,v 1.3 2006/03/30 13:36:29 flameeyes Exp $

EAPI="prefix"

DESCRIPTION="Virtual for the GNU Internationalization Library"
HOMEPAGE="http://www.gentoo.org/proj/en/gentoo-alt/"
SRC_URI=""
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-macos ~x86-solaris"
IUSE=""
DEPEND=""

# - Use this syntax (defining the various libcs) as this allows to use-mask if the
# dep is not present for some Linux systems; using the !elibc_glibc() syntax
# would lead to problems for libiconv for example
# - Don't put elibc_glibc? ( sys-libs/glibc ) to avoid circular deps between
# that and gcc
RDEPEND="elibc_Darwin? ( sys-devel/gettext )
	elibc_FreeBSD? ( sys-devel/gettext )
	elibc_NetBSD? ( sys-devel/gettext )
	elibc_OpenBSD? ( sys-devel/gettext )
	elibc_DragonFly? ( sys-devel/gettext )"
