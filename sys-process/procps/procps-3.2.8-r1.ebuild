# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-process/procps/procps-3.2.8-r1.ebuild,v 1.1 2010/01/25 03:06:08 robbat2 Exp $

inherit flag-o-matic eutils toolchain-funcs multilib

DESCRIPTION="Standard informational utilities and process-handling tools"
HOMEPAGE="http://procps.sourceforge.net/"
SRC_URI="http://procps.sourceforge.net/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~ia64-linux ~x86-linux"
IUSE="n32 unicode"

RDEPEND=">=sys-libs/ncurses-5.2-r2"

src_unpack() {
	unpack ${A}
	cd "${S}"

	epatch "${FILESDIR}"/3.2.5-top-sort.patch
	epatch "${FILESDIR}"/procps-3.2.7-proc-mount.patch
	epatch "${FILESDIR}"/procps-3.2.3-noproc.patch
	epatch "${FILESDIR}"/procps-3.2.8-toprc-fixup.patch

	# Clean up the makefile
	#  - we do stripping ourselves
	#  - punt fugly gcc flags
	sed -i \
		-e '/install/s: --strip : :' \
		-e '/ALL_CFLAGS += $(call check_gcc,-fweb,)/d' \
		-e '/ALL_CFLAGS += $(call check_gcc,-Wstrict-aliasing=2,)/s,=2,,' \
		-e "/^lib64/s:=.*:=$(get_libdir):" \
		-e 's:-m64::g' \
		-e 's|--owner 0||g' \
		-e 's|--group 0||g' \
		Makefile || die "sed Makefile"

	# mips 2.4.23 headers (and 2.6.x) don't allow PAGE_SIZE to be defined in
	# userspace anymore, so this patch instructs procps to get the
	# value from sysconf().
	epatch "${FILESDIR}"/${PN}-mips-define-pagesize.patch

	# lame unicode stuff checks glibc defines
	sed -i "s:__GNU_LIBRARY__ >= 6:0 == $(use unicode; echo $?):" proc/escape.c || die

	# n32 isn't completly reliable of an ABI on mips64 at the current
	# time.  Eventually, it will be, but for now, we need to make sure
	# procps doesn't try to force it on us.
	if ! use n32 ; then
		epatch "${FILESDIR}"/${PN}-3.2.6-mips-n32_isnt_usable_on_mips64_yet.patch
	fi
}

src_compile() {
	replace-flags -O3 -O2
	emake \
		CC="$(tc-getCC)" \
		CPPFLAGS="${CPPFLAGS}" \
		CFLAGS="${CFLAGS}" \
		LDFLAGS="${LDFLAGS}" \
		|| die "make failed"
}

src_install() {
	emake \
		ln_f="ln -sf" \
		ldconfig="true" \
		DESTDIR="${ED}" \
		install \
		|| die "install failed"

	insinto /usr/include/proc
	doins proc/*.h || die "doins include"

	# we want stripped stuff any case
	chmod u+w "${ED}"/usr/bin/*

	dodoc sysctl.conf BUGS NEWS TODO ps/HACKING

	# compat symlink so people who shouldnt be using libproc can #170077
	dosym libproc-${PV}.so /$(get_libdir)/libproc.so
}

pkg_postinst() {
	einfo "NOTE: With NPTL \"ps\" and \"top\" no longer"
	einfo "show threads. You can use any of: -m m -L -T H"
	einfo "in ps or the H key in top to show them"
}
