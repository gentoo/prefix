# Copyright 1999-2005 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-apps/gawk/gawk-3.1.5.ebuild,v 1.6 2005/10/13 00:11:25 kito Exp $

EAPI="prefix"

inherit eutils toolchain-funcs

DESCRIPTION="GNU awk pattern-matching language"
HOMEPAGE="http://www.gnu.org/software/gawk/gawk.html"
SRC_URI="mirror://gnu/gawk/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc-macos ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE="nls build gnuprefix"
#todo: gnuprefix should become global I think

RDEPEND=""
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

SFFS=${WORKDIR}/filefuncs

src_unpack() {
	unpack ${P}.tar.gz

	# Copy filefuncs module's source over ...
	cp -pPR "${FILESDIR}"/filefuncs "${SFFS}" || die "cp failed"

	cd "${S}"
	epatch "${FILESDIR}"/${P}-core.patch
	epatch "${FILESDIR}"/${P}-gcc4.patch
	epatch "${FILESDIR}"/${PN}-3.1.3-getpgrp_void.patch #fedora
	# support for dec compiler.
	[[ $(tc-getCC) == "ccc" ]] && epatch "${FILESDIR}"/${PN}-3.1.2-dec-alpha-compiler.diff
}

src_compile() {
	econf \
		$(with_bindir) \
		--libexec=${PREFIX}/usr/lib/misc \
		$(use_enable nls) \
		--enable-switch \
		|| die
	emake || die "emake failed"

	cd "${SFFS}"
	emake CC=$(tc-getCC) || die "filefuncs emake failed"
}

src_install() {
	make install DESTDIR="${DEST}" || die "install failed"
	cd "${SFFS}"
	make LIBDIR="$(get_libdir)" install || die "filefuncs install failed"

	dodir /usr/bin
	# In some rare cases, (p)gawk gets installed as (p)gawk- and not
	# (p)gawk-${PV} ...  Also make sure that /bin/(p)gawk is a symlink
	# to /bin/(p)gawk-${PV}.
	local binpath x
	for x in gawk pgawk igawk ; do
		[[ ${x} == "gawk" ]] \
			&& binpath="/bin" \
			|| binpath="/usr/bin"

		if [[ -f ${D}/bin/${x} && ! -f ${D}/bin/${x}-${PV} ]] ; then
			mv -f "${D}"/bin/${x} "${D}"/${binpath}/${x}-${PV}
		elif [[ -f ${D}/bin/${x}- && ! -f ${D}/bin/${x}-${PV} ]] ; then
			mv -f "${D}"/bin/${x}- "${D}"/${binpath}/${x}-${PV}
		elif [[ ${binpath} == "${PREFIX}/usr/bin" && -f ${D}/bin/${x}-${PV} ]] ; then
			mv -f "${D}"/bin/${x}-${PV} "${D}"/${binpath}/${x}-${PV}
		fi

		rm -f "${D}"/bin/${x}
		dosym ${x}-${PV} ${binpath}/${x}
		[[ ${binpath} == "/usr/bin" ]] && dosym /usr/bin/${x}-${PV} /bin/${x}
	done

	rm -f "${D}"/bin/awk
	dodir /usr/bin
	# Compat symlinks
	dosym /bin/gawk-${PV} /usr/bin/gawk
	dosym gawk-${PV} /bin/awk
	dosym /bin/gawk-${PV} /usr/bin/awk
	use gnuprefix && rm -f "${D}"/{,usr/}bin/awk{,-${PV}}

	# Install headers
	insinto /usr/include/awk
	doins "${S}"/*.h || die "ins headers failed"
	# We do not want 'acconfig.h' in there ...
	rm -f "${D}"/usr/include/awk/acconfig.h

	if ! use build ; then
		cd "${S}"
		rm -f "${D}"/usr/share/man/man1/pgawk.1
		dosym gawk.1.gz /usr/share/man/man1/pgawk.1.gz
		use gnuprefix || dosym gawk.1.gz /usr/share/man/man1/awk.1.gz
		dodoc AUTHORS ChangeLog FUTURES LIMITATIONS NEWS PROBLEMS POSIX.STD README
		docinto README_d
		dodoc README_d/*
		docinto awklib
		dodoc awklib/ChangeLog
		docinto pc
		dodoc pc/ChangeLog
		docinto posix
		dodoc posix/ChangeLog
	else
		rm -r "${D}"/usr/share
	fi
}
