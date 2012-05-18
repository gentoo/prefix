# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libiconv/libiconv-1.14.ebuild,v 1.3 2012/04/26 12:08:33 aballier Exp $

EAPI="4"

inherit libtool toolchain-funcs

DESCRIPTION="GNU charset conversion library for libc which doesn't implement it"
HOMEPAGE="http://www.gnu.org/software/libiconv/"
SRC_URI="mirror://gnu/libiconv/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

DEPEND="!sys-libs/glibc
	!sys-apps/man-pages"
RDEPEND="${DEPEND}"

src_prepare() {
	# Make sure that libtool support is updated to link "the linux way" on
	# FreeBSD.
	elibtoolize
}

src_configure() {
	# In Prefix we want to have the same header declaration on every
	# platform, so make configure find that it should do
	# "const char * *inbuf"
	export am_cv_func_iconv=no

	# Disable NLS support because that creates a circular dependency
	# between libiconv and gettext
	econf \
		--docdir="\$(datarootdir)/doc/${PF}/html" \
		--disable-nls \
		--enable-shared \
		--enable-static
}

src_install() {
	default

	# Install in /lib as utils installed in /lib like gnutar
	# can depend on this
	gen_usr_ldscript -a iconv charset
}
