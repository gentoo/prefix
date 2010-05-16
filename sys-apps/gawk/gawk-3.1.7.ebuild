# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/gawk/gawk-3.1.7.ebuild,v 1.2 2010/04/25 23:09:30 flameeyes Exp $

inherit eutils toolchain-funcs multilib libtool

DESCRIPTION="GNU awk pattern-matching language"
HOMEPAGE="http://www.gnu.org/software/gawk/gawk.html"
SRC_URI="mirror://gnu/gawk/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x64-freebsd ~x86-freebsd ~hppa-hpux ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls"

RDEPEND=""
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

SFFS=${WORKDIR}/filefuncs

src_unpack() {
	unpack ${A}

	# Copy filefuncs module's source over ...
	cp -r "${FILESDIR}"/filefuncs "${SFFS}" || die "cp failed"

	cd "${S}"
	epatch "${FILESDIR}"/${PN}-3.1.6-gnuinfo.patch #249130

	# on solaris, we have stupid /usr/bin/awk, but gcc,
	# which's preprocessor understands '\'-linebreaks
	epatch "${FILESDIR}"/${PN}-3.1.5-stupid-awk-clever-cc.patch
	epatch "${FILESDIR}"/${PN}-3.1.6-mint.patch
	elibtoolize # needed for FreeMiNT
}

src_compile() {
	local bindir="${EPREFIX}"/usr/bin
	use userland_GNU && bindir="${EPREFIX}"/bin
	econf \
		--bindir="${bindir}" \
		--libexec='$(libdir)/misc' \
		$(use_enable nls) \
		--disable-libsigsegv \
		--enable-switch \
		|| die
	emake || die "emake failed"

	if [[ $(get_libname) != .irrelevant ]] ; then

	cd "${SFFS}"
	emake CC="$(tc-getCC)" LIBDIR="${EPREFIX}/$(get_libdir)" || die "filefuncs emake failed"

	fi
}

src_install() {
	emake install DESTDIR="${D}" || die "install failed"

	if [[ $(get_libname) != .irrelevant ]] ; then

	cd "${SFFS}"
	emake LIBDIR="${EPREFIX}/$(get_libdir)" install || die "filefuncs install failed"

	fi

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
