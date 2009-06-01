# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/virtual/libintl/libintl-0.ebuild,v 1.6 2008/01/25 19:42:14 grobian Exp $

DESCRIPTION="Virtual for the GNU Internationalization Library"
HOMEPAGE="http://www.gentoo.org/proj/en/gentoo-alt/"
SRC_URI=""
LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE=""
DEPEND=""

# - Use this syntax (defining the various libcs) as this allows to use-mask if the
# dep is not present for some Linux systems; using the !elibc_glibc() syntax
# would lead to problems for libiconv for example
# - Don't put elibc_glibc? ( sys-libs/glibc ) to avoid circular deps between
# that and gcc
RDEPEND="!elibc_glibc? ( sys-devel/gettext )"
