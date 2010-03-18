# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/libiconv/libiconv-1.13.1.ebuild,v 1.1 2009/08/10 10:37:21 aballier Exp $

inherit eutils multilib flag-o-matic toolchain-funcs autotools

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

src_unpack() {
	unpack ${A}
	cd "${S}"

	# This patch is needed as libiconv 1.10 provides (and uses) new functions
	# and they are not present in the old libiconv.so, and this breaks the
	# ${DESTDIR} != ${prefix} that we use. It's a problem for Solaris, but we
	# don't have to deal with it for now.
	#epatch "${FILESDIR}"/${PN}-1.10-link.patch

	epatch "${FILESDIR}"/${P}-mint.patch

	if [[ ${CHOST} == *-winnt* ]]; then
		epatch "${FILESDIR}"/${P}-winnt.patch

		find "${S}" -name 'libtool.m4' | xargs rm

		AT_M4DIR="${S}/srcm4 ${S}/m4" eautoreconf # required for winnt support
		cd "${S}"/libcharset
		AT_M4DIR="${S}/srcm4 ${S}/m4" eautoreconf # required for winnt support
		cd "${S}"/preload
		AT_M4DIR="${S}/srcm4 ${S}/m4" eautoreconf # required for winnt support
	else
		# Make sure that libtool support is updated to link "the linux way" on
		# FreeBSD.
		elibtoolize
	fi
}

src_compile() {
	# In Prefix we want to have the same header declaration on every
	# platform, so make configure find that it should do
	# "const char * *inbuf"
	export am_cv_func_iconv=no

	# Install in /lib as utils installed in /lib like gnutar
	# can depend on this

	# Disable NLS support because that creates a circular dependency
	# between libiconv and gettext

	econf \
		--disable-nls \
		--enable-shared \
		--enable-static \
		 || die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" docdir="${EPREFIX}/usr/share/doc/${PF}/html" install || die "make install failed"

	# Move static libs and creates ldscripts into /usr/lib
	gen_usr_ldscript -a iconv charset
}
