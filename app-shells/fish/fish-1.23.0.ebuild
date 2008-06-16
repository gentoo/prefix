# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-shells/fish/fish-1.23.0.ebuild,v 1.2 2008/06/15 22:27:56 loki_val Exp $

EAPI="prefix"

inherit eutils autotools

DESCRIPTION="fish is the Friendly Interactive SHell"
HOMEPAGE="http://fishshell.org/"
SRC_URI="http://fishshell.org/files/${PV}/${P}.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x86-solaris"
IUSE="X"
RDEPEND="sys-libs/ncurses
	sys-devel/bc
	www-client/htmlview
	X? ( x11-misc/xsel )"
DEPEND="${RDEPEND}
	app-doc/doxygen"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-glibc-2.8.patch
	epatch "${FILESDIR}"/fish-1.22.3-gettext.patch
	epatch "${FILESDIR}"/fish-1.23.0-gentoo-alt.patch
	eautoreconf
}

src_compile() {
	# Set things up for fish to be a default shell.
	# It has to be in /bin in case /usr is unavailable.
	# Also, all of its utilities have to be in /bin.
	econf \
		docdir="${EPREFIX}"/usr/share/doc/${PF} \
		--without-xsel \
		--bindir="${EPREFIX}"/bin \
		|| die "econf failed"
	emake || die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install
}

pkg_postinst() {
	elog
	elog "To use ${PN} as your default shell, you need to add ${EPREFIX}/bin/${PN}"
	elog "to ${EPREFIX}/etc/shells."
	elog
	ewarn "Many files moved to ${EROOT}usr/share/fish/completions from /etc/fish.d/."
	ewarn "Delete everything in ${EROOT}etc/fish.d/ except fish_interactive.fish."
	ewarn "Otherwise, fish won't notice updates to the installed files,"
	ewarn "because the ones in /etc will override the new ones in /usr."
	echo
}
