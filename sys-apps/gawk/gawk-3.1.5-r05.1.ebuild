# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/gawk/gawk-3.1.5-r5.ebuild,v 1.9 2007/12/11 10:19:43 vapier Exp $

inherit eutils toolchain-funcs multilib

DESCRIPTION="GNU awk pattern-matching language"
HOMEPAGE="http://www.gnu.org/software/gawk/gawk.html"
SRC_URI="mirror://gnu/gawk/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
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

	# ipv6 patch breaks interix build!
	[[ ${CHOST} == *-interix* ]] || epatch "${FILESDIR}"/${P}-ipv6.patch

	epatch "${FILESDIR}"/${P}-mbread.patch
	epatch "${FILESDIR}"/${P}-freewstr2.patch #135931 #188740
	# on solaris, we have stupid /usr/bin/awk, but gcc,
	# which's preprocessor understands '\'-linebreaks
	epatch "${FILESDIR}"/${P}-stupid-awk-clever-cc.patch
}

src_compile() {
	local bindir="${EPREFIX}"/usr/bin
	use userland_GNU && bindir="${EPREFIX}"/bin
	econf \
		--bindir="${bindir}" \
		--libexec='$(libdir)/misc' \
		$(use_enable nls) \
		--enable-switch \
		|| die
	emake || die "emake failed"

	cd "${SFFS}"
	emake CC=$(tc-getCC) LIBDIR="${EPREFIX}/$(get_libdir)" || die "filefuncs emake failed"
}

src_install() {
	emake install DESTDIR="${D}" || die "install failed"
	cd "${SFFS}"
	emake LIBDIR="${EPREFIX}/$(get_libdir)" install || die "filefuncs install failed"

	dodir /usr/bin
	# In some rare cases, (p)gawk gets installed as (p)gawk- and not
	# (p)gawk-${PV} ...  Also make sure that /bin/(p)gawk is a symlink
	# to /bin/(p)gawk-${PV}.
	local bindir=/usr/bin binpath= x=
	use userland_GNU && bindir=/bin
	for x in gawk pgawk igawk ; do
		[[ ${x} == "gawk" ]] \
			&& binpath=${bindir} \
			|| binpath=/usr/bin

		if [[ -f ${ED}/${bindir}/${x} && ! -f ${ED}/${bindir}/${x}-${PV} ]] ; then
			mv -f "${ED}"/${bindir}/${x} "${ED}"/${binpath}/${x}-${PV}
		elif [[ -f ${ED}/${bindir}/${x}- && ! -f ${ED}/${bindir}/${x}-${PV} ]] ; then
			mv -f "${ED}"/${bindir}/${x}- "${ED}"/${binpath}/${x}-${PV}
		elif [[ ${binpath} == "/usr/bin" && -f ${ED}/${bindir}/${x}-${PV} ]] ; then
			mv -f "${ED}"/${bindir}/${x}-${PV} "${ED}"/${binpath}/${x}-${PV}
		fi

		rm -f "${ED}"/${bindir}/${x}
		[[ -x "${ED}"/${binpath}/${x}-${PV} ]] && dosym ${x}-${PV} ${binpath}/${x}
		if use userland_GNU ; then
			[[ ${binpath} == "/usr/bin" ]] && dosym /usr/bin/${x}-${PV} /bin/${x}
		fi
	done

	rm -f "${ED}"/bin/awk
	dodir /usr/bin
	# Compat symlinks
	dosym gawk-${PV} ${bindir}/awk
	dosym ${bindir}/gawk-${PV} /usr/bin/awk
	if use userland_GNU ; then
		dosym /bin/gawk-${PV} /usr/bin/gawk
	else
		rm -f "${ED}"/{,usr/}bin/awk{,-${PV}}
	fi

	# Install headers
	insinto /usr/include/awk
	doins "${S}"/*.h || die "ins headers failed"
	# We do not want 'acconfig.h' in there ...
	rm -f "${ED}"/usr/include/awk/acconfig.h

	cd "${S}"
	rm -f "${ED}"/usr/share/man/man1/pgawk.1
	dosym gawk.1 /usr/share/man/man1/pgawk.1
	if use userland_GNU ; then
		dosym gawk.1 /usr/share/man/man1/awk.1
	fi
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
