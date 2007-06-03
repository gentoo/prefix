# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-editors/joe/joe-3.5.ebuild,v 1.11 2007/05/25 16:46:43 armin76 Exp $

EAPI="prefix"

inherit flag-o-matic eutils

DESCRIPTION="A free ASCII-Text Screen Editor for UNIX"
HOMEPAGE="http://sourceforge.net/projects/joe-editor/"
SRC_URI="mirror://sourceforge/joe-editor/${P}.tar.gz"

LICENSE="GPL-1"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~sparc-solaris ~x86 ~x86-macos"
IUSE="xterm"

DEPEND=">=sys-libs/ncurses-5.2-r2"
RDEPEND="xterm? ( >=x11-terms/xterm-215-r1 )"
PROVIDE="virtual/editor"

pkg_setup() {
	if use xterm && ! built_with_use x11-terms/xterm paste64; then
		die "For full xterm clipboard support build x11-terms/xterm with USE=paste64"
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"/rc

	# Enable xterm mouse support in the rc files
	if use xterm; then
		for i in *rc*.in; do
			sed -e 's/^ -\(mouse\|joexterm\)/-\1/' -i "${i}" || die "sed failed"
		done
	fi
}

src_compile() {
	# Bug 34609 (joe 2.9.8 editor seg-faults on 'find and replace' when compiled with -Os)
	replace-flags "-Os" "-O2"

	econf || die
	emake || die
}

src_install() {
	make install DESTDIR="${D}" || die "make install failed"
	dodoc ChangeLog HACKING HINTS LIST NEWS README TODO
	# remove superfluous documentation, fixes bug #116861
	rm -rf "${ED}"/etc/joe/doc
}

pkg_postinst() {
	if use xterm; then
		elog "To enable full xterm clipboard you need to set the allowWindowOps"
		elog "resources to true. This is usually found in /etc/X11/app-defaults/XTerm"
		elog "This is false by default due to potential security problems on some"
		elog "architectures (see bug #91453)."
	fi
}
