# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect/eselect-1.0.11-r1.ebuild,v 1.2 2008/05/25 06:45:27 corsair Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Modular -config replacement utility"
HOMEPAGE="http://www.gentoo.org/proj/en/eselect/"
SRC_URI="http://dev.gentooexperimental.org/~peper/distfiles/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc bash-completion vim-syntax"

DEPEND="sys-apps/sed
	doc? ( dev-python/docutils )
	|| (
		sys-apps/coreutils
		sys-freebsd/freebsd-bin
		app-admin/realpath
	)"
RDEPEND="sys-apps/sed
	sys-apps/gawk
	sys-apps/file"

src_unpack() {
	unpack ${A}

	cd "${S}"
	epatch "${FILESDIR}/${P}-fix-paludis-command.patch"

	epatch "${FILESDIR}/${PN}-no-pgrep.patch"

	epatch "${FILESDIR}"/${P}-prefix.patch
	eprefixify \
		$(find "${S}"/bin -type f) \
		$(find "${S}"/libs -type f) \
		$(find "${S}"/misc -type f) \
		$(find "${S}"/modules -type f)
}

PDEPEND="vim-syntax? ( app-vim/eselect-syntax )"

src_compile() {
	econf || die "econf failed"
	emake || die "emake failed"

	if use doc ; then
		make html || die "failed to build html"
	fi
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"
	dodoc AUTHORS ChangeLog NEWS README TODO doc/*.txt
	use doc && dohtml *.html doc/*

	# we don't use bash-completion.eclass since eselect
	# is listed in RDEPEND.
	if use bash-completion ; then
		insinto /usr/share/bash-completion
		newins misc/${PN}.bashcomp ${PN} || die
	fi
}

pkg_postinst() {
	if use bash-completion ; then
		elog "To enable command-line completion for eselect, run:"
		elog
		elog "  eselect bashcomp enable eselect"
		elog
	fi
}
