# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-sound/lame/lame-3.97.ebuild,v 1.1 2006/11/10 17:15:19 flameeyes Exp $

EAPI="prefix"

WANT_AUTOMAKE="latest"
WANT_AUTOCONF="latest"

inherit flag-o-matic toolchain-funcs eutils autotools

DESCRIPTION="LAME Ain't an MP3 Encoder"
HOMEPAGE="http://lame.sourceforge.net"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86"
IUSE="gtk debug mp3rtp"

RDEPEND=">=sys-libs/ncurses-5.2
	gtk? ( =x11-libs/gtk+-1.2* )"
DEPEND="${RDEPEND}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	# The frontened tries to link staticly, but we prefer shared libs
	epatch "${FILESDIR}"/${PN}-3.96.1-shared-frontend.patch

	# If ccc (alpha compiler) is installed on the system, the default
	# configure is broken, fix it to respect CC.  This is only
	# directly broken for ARCH=alpha but would affect anybody with a
	# ccc binary in their PATH.  Bug #41908  (26 Jul 2004 agriffis)
	epatch "${FILESDIR}"/${PN}-3.96-ccc.patch

	# Make sure -lm is linked in the library to fix other programs linking to
	# this while using --as-needed
	epatch "${FILESDIR}"/${PN}-3.96.1-asneeded.patch

	AT_M4DIR="${S}" eautoreconf || die
	epunt_cxx # embedded bug #74498
}

src_compile() {
	# take out -fomit-frame-pointer from CFLAGS if k6-2
	is-flag "-march=k6-3" && filter-flags "-fomit-frame-pointer"
	is-flag "-march=k6-2" && filter-flags "-fomit-frame-pointer"
	is-flag "-march=k6" && filter-flags "-fomit-frame-pointer"

	[ "`gcc-fullversion`" == "3.3.2" ] && replace-flags -march=2.0 -march=1.0

	# The user sets compiler optimizations... But if you'd like
	# lame to choose it's own... uncomment one of these (experiMENTAL)
	# myconf="${myconf} --enable-expopt=full \
	# myconf="${myconf} --enable-expopt=norm \

	econf \
		--enable-shared \
		$(use_enable debug debug norm) \
		$(use_enable gtk mp3x) \
		$(use_enable mp3rtp mp3rtp) \
		${myconf} || die "econf failed"

	emake || die "emake failed"
}

src_install() {
	make DESTDIR="${D}" pkghtmldir="${EPREFIX}/usr/share/doc/${PF}/html" install || die

	dodoc API ChangeLog HACKING README* STYLEGUIDE TODO USAGE
	dohtml misc/lameGUI.html Dll/LameDLLInterface.htm

	dobin "${S}"/misc/mlame || die
}

pkg_postinst(){
	if use mp3rtp ; then
	    ewarn "Warning, support for the encode-to-RTP program, 'mp3rtp'"
	    ewarn "is broken as of August 2001."
	    ewarn " "
	fi
}
