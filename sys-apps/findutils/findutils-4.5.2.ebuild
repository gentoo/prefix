# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/findutils/findutils-4.5.2.ebuild,v 1.1 2008/11/27 23:57:06 vapier Exp $

inherit eutils flag-o-matic toolchain-funcs multilib

SELINUX_PATCH="findutils-4.3.12-selinux.diff"

DESCRIPTION="GNU utilities for finding files"
HOMEPAGE="http://www.gnu.org/software/findutils/"
SRC_URI="ftp://alpha.gnu.org/gnu/${PN}/${P}.tar.gz
	mirror://gnu/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls selinux static"

RDEPEND="selinux? ( sys-libs/libselinux )
	nls? ( virtual/libintl )"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# IRIX needs an extra cast
	epatch "${FILESDIR}"/${PN}-4.3.2-irix.patch

	# interix does not have any means of retrieving a list of
	# mounted filesystems.
	# Need to patch configure directly besides ls-mntd-fs.m4,
	# because during bootstrap not all m4-files might be installed.
	cp -a configure{,.ts} || die
	cp -a find/fstype.c{,.ts} || die
	cp -a gnulib/lib/mountlist.c{,.ts} || die
	cp -a gnulib/m4/ls-mntd-fs.m4{,.ts} || die
	epatch "${FILESDIR}"/${PN}-4.3.11-interix.patch
	epatch "${FILESDIR}"/${PN}-4.5.1-mint.patch
	# avoid regeneration
	touch -r configure{.ts,} || die
	touch -r find/fstype.c{.ts,} || die
	touch -r gnulib/lib/mountlist.c{.ts,} || die
	touch -r gnulib/m4/ls-mntd-fs.m4{.ts,} || die

	# Don't build or install locate because it conflicts with slocate,
	# which is a secure version of locate.  See bug 18729
	sed -i '/^SUBDIRS/s/locate//' Makefile.in

	use selinux && epatch "${FILESDIR}/${SELINUX_PATCH}"
}

src_compile() {
	use static && append-ldflags -static

	local myconf
	[[ ${USERLAND} != "GNU" ]] && \
		myconf=" --program-prefix=g"

	if echo "#include <regex.h>" | $(tc-getCPP) | grep re_set_syntax > /dev/null ; then
		myconf="${myconf} --without-included-regex"
	fi

	econf \
		$(use_enable nls) \
		--libexecdir="${EPREFIX}"/usr/$(get_libdir)/find \
		${myconf} \
		|| die "configure failed"
	emake AR="$(tc-getAR)" || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" install || die
	rm -f "${ED}"/usr/$(get_libdir)/charset.alias
	dodoc NEWS README TODO ChangeLog
}
