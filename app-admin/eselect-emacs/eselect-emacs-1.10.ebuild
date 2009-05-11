# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-emacs/eselect-emacs-1.10.ebuild,v 1.1 2009/05/07 23:52:42 ulm Exp $

DESCRIPTION="Manage multiple Emacs versions on one system"
HOMEPAGE="http://www.gentoo.org/proj/en/lisp/emacs/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=">=app-admin/eselect-1.0.10
	~app-admin/eselect-ctags-${PV}"

src_unpack() {
	unpack ${A}
	cd "${S}"

	sed -i -e "/^\(bindir\|man1dir\|infodir\|envdir\)=/s|=|=\"${EPREFIX}\"|" \
		emacs.eselect || die "failed to prefixify"
}

src_install() {
	insinto /usr/share/eselect/modules
	doins {emacs,etags}.eselect || die
	doman {emacs,etags}.eselect.5 || die
	dodoc ChangeLog || die
}
