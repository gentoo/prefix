# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-misc/mc/mc-4.6.1-r4.ebuild,v 1.15 2008/09/14 02:04:27 solar Exp $

inherit flag-o-matic eutils

U7Z_PV="4.29"
U7Z="u7z-${U7Z_PV}.tar.bz2"
DESCRIPTION="GNU Midnight Commander cli-based file manager"
HOMEPAGE="http://www.gnu.org/software/mc/"
SRC_URI="http://www.ibiblio.org/pub/Linux/utils/file/managers/${PN}/${P}.tar.gz
	mirror://gentoo/${P}-utf8-r2.patch.bz2
	7zip? ( http://sgh-punk.narod.ru/files/u7z/${U7Z} )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x86-solaris"
IUSE="7zip X gpm ncurses nls samba slang unicode"

RDEPEND="kernel_linux? ( >=sys-fs/e2fsprogs-1.19 )
	ncurses? ( >=sys-libs/ncurses-5.2-r5 )
	=dev-libs/glib-2*
	gpm? ( >=sys-libs/gpm-1.19.3 )
	slang? ( >=sys-libs/slang-1.4 )
	samba? ( >=net-fs/samba-3.0.0 )
	X? ( x11-libs/libX11
		x11-libs/libICE
		x11-libs/libXau
		x11-libs/libXdmcp
		x11-libs/libSM )
	x86? ( 7zip? ( >=app-arch/p7zip-4.16 ) )
	ppc? ( 7zip? ( >=app-arch/p7zip-4.16 ) )
	amd64? ( 7zip? ( >=app-arch/p7zip-4.16 ) )"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

pkg_setup() {
	if use unicode && ! use slang ; then
		eerror "You must either disable unicode useflag or, if you want a"
		eerror "unicode-aware mc, set the slang useflag as well."
		die "set slang or unset unicode"
	fi
}

src_unpack() {
	if ( use x86 || use amd64 || use ppc ) && use 7zip; then
		unpack ${U7Z}
	fi
	unpack ${P}.tar.gz
	cd "${S}"

	epatch "${FILESDIR}"/${P}-find.patch
	if ( use x86 || use amd64 || use ppc ) && use 7zip; then
		epatch "${FILESDIR}"/${PN}-4.6.0-7zip.patch
	fi
	epatch "${FILESDIR}"/${P}-largefile.patch

	# Don't crash on invalid mtimes
	# Bug #184296
	epatch "${FILESDIR}"/${P}-invalid-mtime.patch

	if use slang && use unicode; then
		epatch "${DISTDIR}"/${P}-utf8-r2.patch.bz2
	fi
	epatch "${FILESDIR}"/${P}-nonblock.patch
	epatch "${FILESDIR}"/${P}-bash-all.patch

	# Prevent lazy bindings in cons.saver binary. (bug #135009)
	#  - not using bindnow-flags() because cons.saver is only built on GNU/Linux
	sed -i -e "s:^\(cons_saver_LDADD = .*\):\1 -Wl,-z,now:" \
		src/Makefile.in

	# docs try to run the files it just built while trying convert .1 to .hlp files.
	# this will never work for cross compiles, so we simply don't make docs.
	if tc-is-cross-compiler; then
		sed -i -e s/'lib doc syntax'/'lib syntax'/ Makefile.in
	fi

	# Correctly generate charset.alias.
	# Fixes bugs  71275, 105960 and 169678
	epatch "${FILESDIR}"/${P}-charset-locale-aliases.patch
}

src_compile() {
	append-flags -I"${EPREFIX}"/usr/include/gssapi

	filter-flags -malign-double

	local myconf=""

	if ! use slang && ! use ncurses ; then
		myconf="${myconf} --with-screen=mcslang"
	elif use ncurses && ! use slang ; then
		myconf="${myconf} --with-screen=ncurses"
	else
		use slang && myconf="${myconf} --with-screen=slang"
	fi

	myconf="${myconf} `use_with gpm gpm-mouse`"

	use nls \
		&& myconf="${myconf} --with-included-gettext" \
		|| myconf="${myconf} --disable-nls"

	myconf="${myconf} `use_with X x`"

	use samba \
		&& myconf="${myconf} --with-samba --with-configdir='${EPREFIX}'/etc/samba --with-codepagedir='${EPREFIX}'/var/lib/samba/codepages --with-privatedir='${EPREFIX}'/etc/samba/private" \
		|| myconf="${myconf} --without-samba"

	econf \
		--with-vfs \
		--with-ext2undel \
		--with-edit \
		--enable-charset \
	${myconf} || die "econf failed"

	emake || die "emake failed"
}

src_install() {
	cat ${FILESDIR}/chdir-4.6.0.gentoo >>\
		${S}/lib/mc-wrapper.sh

	make install DESTDIR="${D}" || die "make install failed"

	# install cons.saver setuid, to actually work
	fperms u+s /usr/$(get_libdir)/mc/cons.saver

	dodoc ChangeLog AUTHORS MAINTAINERS FAQ INSTALL* NEWS README*

	insinto /usr/share/mc
	doins "${FILESDIR}"/mc.gentoo
	doins "${FILESDIR}"/mc.ini

	if ( use x86 || use amd64 || use ppc ) && use 7zip; then
		cd ../${U7Z_PV}
		exeinto /usr/share/mc/extfs
		doexe u7z
		dodoc readme.u7z
		newdoc ChangeLog ChangeLog.u7z
	fi

	insinto /usr/share/mc/syntax
	doins "${FILESDIR}"/ebuild.syntax
	cd "${ED}"/usr/share/mc/syntax
	epatch "${FILESDIR}"/${PN}-4.6.0-ebuild-syntax.patch
}

pkg_postinst() {
	elog "Add the following line to your ~/.bashrc to"
	elog "allow mc to chdir to its latest working dir at exit"
	elog ""
	elog "# Midnight Commander chdir enhancement"
	elog "if [ -f /usr/share/mc/mc.gentoo ]; then"
	elog "	. /usr/share/mc/mc.gentoo"
	elog "fi"
}
