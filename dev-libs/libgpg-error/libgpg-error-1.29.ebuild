# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit libtool ltprune multilib-minimal toolchain-funcs autotools prefix

DESCRIPTION="Contains error handling functions used by GnuPG software"
HOMEPAGE="http://www.gnupg.org/related_software/libgpg-error"
SRC_URI="mirror://gnupg/${PN}/${P}.tar.bz2
	https://github.com/gpg/libgpg-error/commit/e35749023ca68de6f1f85d3072f7b36fd6f6fe7c.patch -> ${P}-solaris.patch"

LICENSE="GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-cygwin ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="common-lisp nls static-libs"

RDEPEND="nls? ( >=virtual/libintl-0-r1[${MULTILIB_USEDEP}] )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

MULTILIB_CHOST_TOOLS=(
	/usr/bin/gpg-error-config
)
MULTILIB_WRAPPED_HEADERS=(
	/usr/include/gpg-error.h
	/usr/include/gpgrt.h
)

src_prepare() {
	default
	eapply "${DISTDIR}"/${P}-solaris.patch
	eapply "${FILESDIR}"/1.29-yat2m-dep-exeext.patch
	# autogen is needed for getting a version number, it needs a
	# POSIX compliant shell
	hprefixify "${S}"/autogen.sh
	eautoreconf
	elibtoolize

	# upstream seems not interested in trying to understand (#584330)
	# https://lists.gnupg.org/pipermail/gnupg-devel/2017-March/032671.html
	einfo "Forcing -no-undefined libtool flag ..."
	sed -i -e 's/\$(no_undefined)/-no-undefined/' src/Makefile.in
	eend $? || die
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" econf \
		CC_FOR_BUILD="$(tc-getBUILD_CC)" \
		--enable-threads \
		$(use_enable nls) \
		$(use_enable static-libs static) \
		$(use_enable common-lisp languages) \
		$(multilib_is_native_abi || echo --disable-languages)
}

multilib_src_install_all() {
	einstalldocs
	prune_libtool_files --all
}
