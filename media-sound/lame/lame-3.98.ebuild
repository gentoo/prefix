# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/lame/lame-3.98.ebuild,v 1.7 2009/03/29 17:14:16 beandog Exp $

inherit flag-o-matic toolchain-funcs eutils autotools versionator

DESCRIPTION="LAME Ain't an MP3 Encoder"
HOMEPAGE="http://lame.sourceforge.net"

MY_PV=$(replace_version_separator 1 '')
S=${WORKDIR}/${PN}-${MY_PV}
SRC_URI="mirror://sourceforge/${PN}/${PN}-${MY_PV}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="debug mmx mp3rtp sndfile"

RDEPEND=">=sys-libs/ncurses-5.2
	sndfile? ( >=media-libs/libsndfile-1.0.2 )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	mmx? ( dev-lang/nasm )"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# The frontened tries to link staticly, but we prefer shared libs
	epatch "${FILESDIR}"/${P}-shared-frontend.patch

	# If ccc (alpha compiler) is installed on the system, the default
	# configure is broken, fix it to respect CC.  This is only
	# directly broken for ARCH=alpha but would affect anybody with a
	# ccc binary in their PATH.  Bug #41908  (26 Jul 2004 agriffis)
	epatch "${FILESDIR}"/${PN}-3.96-ccc.patch

	# Patch gtk stuff, otherwise eautoreconf dies
	epatch "${FILESDIR}"/${PN}-3.98-gtk-path.patch

	# Fix build of mp3rtp, bug #231541
	# Dont prevent stdint.h from being included when it's in fact needed
	epatch "${FILESDIR}"/${PN}-3.98-stdint.patch

	# PIC Fix by the PaX Team, bug #93279
	epatch "${FILESDIR}"/${PN}-3.98-pic-fix.patch

	# Let it use proper %if statements for marking stacks as non executable
	epatch "${FILESDIR}"/${PN}-3.98-execstacks.patch

	# It needs $(ECHO) to be defined but it seems libtool 2.2 doesn't define it
	# anymore
	epatch "${FILESDIR}/${P}-echo.patch"

	# It fails parallel make otherwise when enabling nasm...
	mkdir "${S}/libmp3lame/i386/.libs" || die

	AT_M4DIR="${S}" eautoreconf
	epunt_cxx # embedded bug #74498
}

src_compile() {
	use sndfile && myconf="--with-fileio=sndfile"
	# The user sets compiler optimizations... But if you'd like
	# lame to choose it's own... uncomment one of these (experiMENTAL)
	# myconf="${myconf} --enable-expopt=full \
	# myconf="${myconf} --enable-expopt=norm \

	econf \
		--enable-shared \
		$(use_enable debug debug norm) \
		--disable-mp3x \
		$(use_enable mmx nasm) \
		$(use_enable mp3rtp) \
		${myconf} || die "econf failed"

	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" pkghtmldir="${EPREFIX}/usr/share/doc/${PF}/html" install || die

	dodoc API ChangeLog HACKING README* STYLEGUIDE TODO USAGE || die
	dohtml misc/lameGUI.html Dll/LameDLLInterface.htm || die

	dobin "${S}"/misc/mlame || die
}

pkg_postinst(){
	if use mp3rtp ; then
	    ewarn "Warning, support for the encode-to-RTP program, 'mp3rtp'"
	    ewarn "is broken as of August 2001."
	    ewarn " "
	fi
}
