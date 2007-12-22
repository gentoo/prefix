# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect-ctags/eselect-ctags-1.3.ebuild,v 1.1 2007/12/21 08:45:39 ulm Exp $

EAPI="prefix"

inherit eutils

MY_P="eselect-emacs-${PV}"
DESCRIPTION="Manages ctags implementations"
HOMEPAGE="http://www.gentoo.org/proj/en/lisp/emacs/"
SRC_URI="mirror://gentoo/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc-macos ~x86 ~x86-fbsd ~x86-macos ~x86-solaris"
IUSE=""

DEPEND=""
RDEPEND=">=app-admin/eselect-1.0.10
	!<=app-admin/eselect-emacs-1.3"

S="${WORKDIR}/${MY_P}"

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify {ctags,emacs}.eselect
}

src_install() {
	insinto /usr/share/eselect/modules
	doins ctags.eselect || die "doins failed"
	doman ctags.eselect.5 || die "doman failed"
}
