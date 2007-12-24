# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/libiconv/libiconv-0.ebuild,v 1.3 2007/07/11 05:04:22 mr_bones_ Exp $

EAPI="prefix"

DESCRIPTION="Virtual for the GNU conversion library"
HOMEPAGE="http://www.gentoo.org/proj/en/gentoo-alt/"
SRC_URI=""
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ia64-hpux ~ppc-aix ~ppc-macos ~sparc-solaris ~sparc64-solaris ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"
IUSE=""
DEPEND=""

# - Use this syntax (defining the various libcs) as this allows to use-mask if the
# dep is not present for some Linux systems; using the !elibc_glibc() syntax
# would lead to problems for libiconv for example
# - Don't put elibc_glibc? ( sys-libs/glibc ) to avoid circular deps between
# that and gcc
RDEPEND="!elibc_glibc? ( dev-libs/libiconv )"
