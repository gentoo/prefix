# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.17.50.0.13.ebuild,v 1.1 2007/03/16 22:34:07 vapier Exp $

EAPI="prefix"

PATCHVER="1.0"
UCLIBC_PATCHVER="1.0"
ELF2FLT_VER=""
inherit toolchain-binutils

# ARCH - packages to test before marking
KEYWORDS="~amd64 ~sparc-solaris ~x86 ~x86-solaris"
