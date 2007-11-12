# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.18-r1.ebuild,v 1.10 2007/11/11 19:56:06 vapier Exp $

EAPI="prefix"

PATCHVER="1.5"
ELF2FLT_VER=""
inherit toolchain-binutils autotools

KEYWORDS="~amd64 ~ia64 ~ia64-hpux ~sparc-solaris ~x86-solaris"

src_unpack() {
	toolchain-binutils_src_unpack

	cd "${S}"
	# http://sourceware.org/bugzilla/show_bug.cgi?id=5146
	epatch "${FILESDIR}"/${PV}-bfd-alloca.patch
	# http://sourceware.org/bugzilla/show_bug.cgi?id=5147
	epatch "${FILESDIR}"/${PV}-gprof-fabs.patch
	# http://sourceware.org/bugzilla/show_bug.cgi?id=5160
	epatch "${FILESDIR}"/${PV}-bfd-bufsz.patch
}

src_compile() {
	if has noinfo "${FEATURES}" \
	|| ! type -p makeinfo >/dev/null
	then
		# disable regeneration of info pages #193364
		export EXTRA_EMAKE="MAKEINFO=true"
	fi

	# GNU ld is not recommended (or does not work) on hpux,
	# so the native one is linked in.
	case "${CTARGET}" in
	*-hpux*) EXTRA_ECONF="--without-gnu-ld" ;;
	esac

	toolchain-binutils_src_compile
}

src_install() {
	toolchain-binutils_src_install

	case "${CTARGET}" in
	*-hpux*)
		ln -s /usr/ccs/bin/ld "${ED}${BINPATH}"/ld || die "Cannot create ld symlink"
		;;
	esac
}
