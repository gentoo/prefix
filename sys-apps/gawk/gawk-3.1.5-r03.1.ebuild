# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/gawk/gawk-3.1.5-r3.ebuild,v 1.4 2007/04/01 10:16:10 hansmi Exp $

EAPI="prefix"

inherit eutils toolchain-funcs multilib

DESCRIPTION="GNU awk pattern-matching language"
HOMEPAGE="http://www.gnu.org/software/gawk/gawk.html"
SRC_URI="mirror://gnu/gawk/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
IUSE="nls"

RDEPEND=""
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

SFFS=${WORKDIR}/filefuncs

src_unpack() {
	unpack ${P}.tar.gz

	# Copy filefuncs module's source over ...
	cp -r "${FILESDIR}"/filefuncs "${SFFS}" || die "cp failed"

	cd "${S}"
	epatch "${FILESDIR}"/${P}-core.patch
	epatch "${FILESDIR}"/${P}-gcc4.patch
	epatch "${FILESDIR}"/${P}-autotools-crap.patch #139397
	# Patches from Fedora
	epatch "${FILESDIR}"/${PN}-3.1.3-getpgrp_void.patch
	epatch "${FILESDIR}"/${P}-fieldwidths.patch #127163
	epatch "${FILESDIR}"/${P}-binmode.patch
	epatch "${FILESDIR}"/${P}-num2str.patch
	epatch "${FILESDIR}"/${P}-internal.patch
	epatch "${FILESDIR}"/${P}-numflags.patch
	epatch "${FILESDIR}"/${P}-syntaxerror.patch
	epatch "${FILESDIR}"/${P}-wconcat.patch
	epatch "${FILESDIR}"/${P}-freewstr.patch #135931
	# on solaris, we have stupid /usr/bin/awk, but gcc,
	# which's preprocessor understands '\'-linebreaks
	epatch "${FILESDIR}"/${P}-stupid-awk-clever-cc.patch
}

src_compile() {
	econf \
		$(with_bindir) \
		--libexec='$(libdir)/misc' \
		$(use_enable nls) \
		--enable-switch \
		|| die
	emake || die "emake failed"

	cd "${SFFS}"
	emake CC=$(tc-getCC) || die "filefuncs emake failed"
}

src_install() {
	make install DESTDIR="${D}" || die "install failed"
	cd "${SFFS}"
	make LIBDIR="${EPREFIX}/$(get_libdir)" install || die "filefuncs install failed"

	dodir /usr/bin
	# In some rare cases, (p)gawk gets installed as (p)gawk- and not
	# (p)gawk-${PV} ...  Also make sure that /bin/(p)gawk is a symlink
	# to /bin/(p)gawk-${PV}.
	local binpath x
	for x in gawk pgawk igawk ; do
		[[ ${x} == "gawk" ]] \
			&& binpath="/bin" \
			|| binpath="/usr/bin"

		if [[ -f ${ED}/bin/${x} && ! -f ${ED}/bin/${x}-${PV} ]] ; then
			mv -f "${ED}"/bin/${x} "${ED}"/${binpath}/${x}-${PV}
		elif [[ -f ${ED}/bin/${x}- && ! -f ${ED}/bin/${x}-${PV} ]] ; then
			mv -f "${ED}"/bin/${x}- "${ED}"/${binpath}/${x}-${PV}
		elif [[ ${binpath} == "/usr/bin" && -f ${ED}/bin/${x}-${PV} ]] ; then
			mv -f "${ED}"/bin/${x}-${PV} "${ED}"/${binpath}/${x}-${PV}
		fi

		rm -f "${ED}"/bin/${x}
		dosym ${x}-${PV} ${binpath}/${x}
		[[ ${binpath} == "/usr/bin" ]] && dosym /usr/bin/${x}-${PV} /bin/${x}
	done

	rm -f "${ED}"/bin/awk
	dodir /usr/bin
	# Compat symlinks
	dosym /bin/gawk-${PV} /usr/bin/gawk
	dosym gawk-${PV} /bin/awk
	dosym /bin/gawk-${PV} /usr/bin/awk
	[[ ${USERLAND} != "GNU" ]] && [[ ${EPREFIX%/} == "" ]] && \
		rm -f "${ED}"/{,usr/}bin/awk{,-${PV}}

	# Install headers
	insinto /usr/include/awk
	doins "${S}"/*.h || die "ins headers failed"
	# We do not want 'acconfig.h' in there ...
	rm -f "${ED}"/usr/include/awk/acconfig.h

	cd "${S}"
	rm -f "${ED}"/usr/share/man/man1/pgawk.1
	dosym gawk.1 /usr/share/man/man1/pgawk.1
	[[ ${USERLAND} != "GNU" ]] && [[ ${EPREFIX%/} == "" ]] || \
		dosym gawk.1 /usr/share/man/man1/awk.1
	dodoc AUTHORS ChangeLog FUTURES LIMITATIONS NEWS PROBLEMS POSIX.STD README
	docinto README_d
	dodoc README_d/*
	docinto awklib
	dodoc awklib/ChangeLog
	docinto pc
	dodoc pc/ChangeLog
	docinto posix
	dodoc posix/ChangeLog
}
