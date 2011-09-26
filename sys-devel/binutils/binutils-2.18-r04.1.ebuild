# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/binutils/binutils-2.18-r4.ebuild,v 1.4 2011/09/22 17:29:31 vapier Exp $

PATCHVER="1.10"
ELF2FLT_VER=""
inherit toolchain-binutils autotools

KEYWORDS="~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~sparc-solaris ~x86-solaris"

src_unpack() {
	toolchain-binutils_src_unpack

	cd "${S}"
	# http://sourceware.org/bugzilla/show_bug.cgi?id=5146
	epatch "${FILESDIR}"/${PV}-bfd-alloca.patch
	# http://sourceware.org/bugzilla/show_bug.cgi?id=5147
	epatch "${FILESDIR}"/${PV}-gprof-fabs.patch
	# http://sourceware.org/bugzilla/show_bug.cgi?id=5160
	epatch "${FILESDIR}"/${PV}-bfd-bufsz.patch
	# http://sourceware.org/bugzilla/show_bug.cgi?id=5449
	epatch "${FILESDIR}"/${PV}-bfd-ia64elf.patch
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
	*-interix*) EXTRA_ECONF="--without-gnu-ld --without-gnu-as" ;;
	esac

	toolchain-binutils_src_compile
}

src_install() {
	toolchain-binutils_src_install

	case "${CTARGET}" in
	*-hpux*)
		ln -s /usr/ccs/bin/ld "${ED}${BINPATH}"/ld || die "Cannot create ld symlink"
		;;
    *-interix*)
		ln -s /opt/gcc.3.3/bin/as "${ED}${BINPATH}"/as || die "Cannot create as symlink"
		sed -e "s,@SCRIPTDIR@,${EPREFIX}${LIBPATH}/ldscripts," \
			< "${FILESDIR}"/${PV}-ldwrap-interix.sh \
			> "${ED}${BINPATH}"/ld \
			|| die "Cannot create ld wrapper"
		chmod a+x "${ED}${BINPATH}"/ld

		dodir "${LIBPATH}"/ldscripts
	
		# yes, this is "i586-pc-interix3" for SFU 3.5, SUA 5.2 and SUA 6.0
		# additionally insert the prefix as absolute top search dir...
		for x in /opt/gcc.3.3/i586-pc-interix3/lib/ldscripts/i386pe_posix.*; do
			sed -e 's, SEARCH_DIR("/usr/local/lib"); , ,' \
				-e "s,^\(SEARCH_DIR(\),SEARCH_DIR(\"${EPREFIX}/lib\"); SEARCH_DIR(\"${EPREFIX}/usr/lib\"); \1," \
			< $x \
			> "${ED}${LIBPATH}"/ldscripts/${x##*/} \
			|| die "Cannot occupy ldscripts"
		done
		;;
	esac
}
