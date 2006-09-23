# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/libiconv/libiconv-0.ebuild,v 1.1 2006/04/13 19:56:44 flameeyes Exp $

EAPI="prefix"

DESCRIPTION="Virtual for the GNU conversion library"
HOMEPAGE="http://www.gentoo.org/proj/en/gentoo-alt/"
SRC_URI=""
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86 ~x86-macos"
IUSE=""
DEPEND=""

# - Use this syntax (defining the various libcs) as this allows to use-mask if the
# dep is not present for some Linux systems; using the !elibc_glibc() syntax
# would lead to problems for libiconv for example
# - Don't put elibc_glibc? ( sys-libs/glibc ) to avoid circular deps between
# that and gcc
RDEPEND="elibc_Darwin? ( dev-libs/libiconv )
	elibc_FreeBSD? ( dev-libs/libiconv )
	elibc_NetBSD? ( dev-libs/libiconv )
	elibc_OpenBSD? ( dev-libs/libiconv )
	elibc_DragonFly? ( dev-libs/libiconv )"

