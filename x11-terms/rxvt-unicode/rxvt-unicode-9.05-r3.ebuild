# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/rxvt-unicode/rxvt-unicode-9.05-r3.ebuild,v 1.1 2008/11/01 09:35:13 killerfox Exp $

inherit autotools flag-o-matic

DESCRIPTION="rxvt clone with xft and unicode support"
HOMEPAGE="http://software.schmorp.de/"
SRC_URI="http://dist.schmorp.de/rxvt-unicode/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"
IUSE="truetype perl iso14755 afterimage xterm-color wcwidth vanilla"

# see bug #115992 for modular x deps
RDEPEND="x11-libs/libX11
	x11-libs/libXft
	afterimage? ( media-libs/libafterimage )
	x11-libs/libXrender
	perl? ( dev-lang/perl )"
DEPEND="${RDEPEND}
	dev-util/pkgconfig
	x11-proto/xproto"

src_unpack() {
	unpack ${A}
	cd "${S}"

	if (use xterm-color || use wcwidth); then
		ewarn "You enabled xterm-color or wcwidth or both."
		ewarn "Please note that neither of them are supported by upstream."
		ewarn "You are at your own if you run into problems."
		ebeep 5
	fi

	local tdir=/usr/share/terminfo
	if use xterm-color; then
		epatch doc/urxvt-8.2-256color.patch
		sed -e \
			's/^\(rxvt-unicode\)/\1256/;s/colors#88/colors#256/;s/pairs#256/pairs#32767/' \
			doc/etc/rxvt-unicode.terminfo > doc/etc/rxvt-unicode256.terminfo
		sed -i -e \
			"s~^\(\s\+@TIC@.*\)~\1\n\t@TIC@ -o ${ED}/${tdir} \$(srcdir)/etc/rxvt-unicode256.terminfo~" \
			doc/Makefile.in
	fi

	use wcwidth && epatch doc/wcwidth.patch

	# https://bugs.gentoo.org/show_bug.cgi?id=240165
	epatch ${FILESDIR}/${PN}_no-urgency-if-focused.diff

	if ! use vanilla; then
		ewarn "You are going to include third-party bug fixes/features."
		ewarn "They came without any warranty and are not supported by the"
		ewarn "Gentoo community."
		ebeep 5
		# https://bugs.gentoo.org/show_bug.cgi?id=237271
		epatch ${FILESDIR}/${P}_no-MOTIF-WM-INFO.patch
	fi

	sed -i -e \
		"s~@TIC@ \(\$(srcdir)/etc/rxvt\)~@TIC@ -o ${ED}/${tdir} \1~" \
		doc/Makefile.in

	eautoreconf
}

src_compile() {
	local myconf=''

	use iso14755 || myconf='--disable-iso14755'
	use xterm-color && myconf="$myconf --enable-xterm-colors=256"

	econf --enable-everything \
		$(use_enable truetype xft) \
		$(use_enable afterimage) \
		$(use_enable perl) \
		--disable-text-blink \
		--with-xpm-includes="${EPREFIX}"/usr/include \
		--with-xpm-library="${EPREFIX}"/usr/lib \
		${myconf}

	emake || die

	sed -i \
		-e 's/RXVT_BASENAME = "rxvt"/RXVT_BASENAME = "urxvt"/' \
		"${S}"/doc/rxvt-tabbed || die "tabs sed failed"
}

src_install() {
	make DESTDIR="${D}" install || die

	dodoc README.FAQ Changes
	cd "${S}"/doc
	dodoc README* changes.txt etc/* rxvt-tabbed
}

pkg_postinst() {
	einfo "urxvt now always uses TERM=rxvt-unicode so that the"
	einfo "upstream-supplied terminfo files can be used."
}
