# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gdb/gdb-6.8.50.20090302.8.11.ebuild,v 1.1 2009/03/12 04:31:01 vapier Exp $

inherit flag-o-matic eutils

export CTARGET=${CTARGET:-${CHOST}}
if [[ ${CTARGET} == ${CHOST} ]] ; then
	if [[ ${CATEGORY/cross-} != ${CATEGORY} ]] ; then
		export CTARGET=${CATEGORY/cross-}
	fi
fi

if [[ ${PV} == *.*.*.*.*.* ]] ; then
	inherit versionator rpm
	# fedora version: gdb-6.8.50.20090302-8.fc11.src.rpm
	gvcr() { get_version_component_range "$@"; }
	MY_PV=$(gvcr 1-4)
	RPM="${PN}-${MY_PV}-$(gvcr 5).fc$(gvcr 6).src.rpm"
else
	MY_PV=${PV}
	RPM=
fi

PATCH_VER=""
DESCRIPTION="GNU debugger"
HOMEPAGE="http://sources.redhat.com/gdb/"
if [[ -n ${RPM} ]] ; then
	SRC_URI="http://mirrors.kernel.org/fedora/development/source/SRPMS/${RPM}"
else
	SRC_URI="http://ftp.gnu.org/gnu/gdb/${P}.tar.bz2
		ftp://sources.redhat.com/pub/gdb/releases/${P}.tar.bz2"
fi
SRC_URI="${SRC_URI} ${PATCH_VER:+mirror://gentoo/${P}-patches-${PATCH_VER}.tar.lzma}"

LICENSE="GPL-2 LGPL-2"
[[ ${CTARGET} != ${CHOST} ]] \
	&& SLOT="${CTARGET}" \
	|| SLOT="0"
KEYWORDS="~ppc-aix ~amd64-linux ~x86-linux ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="multitarget nls test vanilla"

RDEPEND=">=sys-libs/ncurses-5.2-r2
	sys-libs/readline"
DEPEND="${RDEPEND}
	app-arch/lzma-utils
	test? ( dev-util/dejagnu )
	nls? ( sys-devel/gettext )"

S=${WORKDIR}/${PN}-${MY_PV}

src_unpack() {
	if [[ -n ${RPM} ]] ; then
		rpm_src_unpack
		cd "${S}"
		rpm_spec_epatch "${WORKDIR}"/gdb.spec
	else
		unpack ${A}
	fi
	cd "${S}"
	if [[ -n ${PATCH_VER} ]] ; then
		use vanilla || EPATCH_SUFFIX="patch" epatch "${WORKDIR}"/patch
	fi
	epatch "${FILESDIR}"/${PN}-6.7.1-solaris.patch
	epatch "${FILESDIR}"/${PN}-6.8-solaris64.patch
	# avoid using internal readline symbols, they are not exported on aix.
	# patch is platform independent, but might reduce performance.
	[[ ${CHOST} == *-aix* ]] && epatch "${FILESDIR}"/${PN}-6.8-tui-rlapi.patch
	strip-linguas -u bfd/po opcodes/po
}

src_compile() {
	strip-unsupported-flags
	econf \
		--disable-werror \
		$(has_version '=sys-libs/readline-5*' && echo --with-system-readline) \
		$(use_enable nls) \
		$(use multitarget && echo --enable-targets=all) \
		|| die
	emake || die
}

src_test() {
	emake check || ewarn "tests failed"
}

src_install() {
	emake \
		DESTDIR="${D}" \
		libdir=/nukeme/pretty/pretty/please includedir=/nukeme/pretty/pretty/please \
		install || die
	rm -r "${D}"/nukeme || die

	# Don't install docs when building a cross-gdb
	if [[ ${CTARGET} != ${CHOST} ]] ; then
		rm -r "${ED}"/usr/share
		return 0
	fi

	dodoc README
	docinto gdb
	dodoc gdb/CONTRIBUTE gdb/README gdb/MAINTAINERS \
		gdb/NEWS gdb/ChangeLog gdb/PROBLEMS
	docinto sim
	dodoc sim/ChangeLog sim/MAINTAINERS sim/README-HACKING

	dodoc "${WORKDIR}"/extra/gdbinit.sample

	# Remove shared info pages
	rm -f "${ED}"/usr/share/info/{annotate,bfd,configure,standards}.info*
	rm -f "${ED}"/usr/share/locale/*/LC_MESSAGES/{annotate,bfd,configure,standards,opcodes}.mo
}

pkg_postinst() {
	# portage sucks and doesnt unmerge files in /etc
	rm -vf "${EROOT}"/etc/skel/.gdbinit
}
