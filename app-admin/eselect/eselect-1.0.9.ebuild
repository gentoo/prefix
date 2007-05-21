# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect/eselect-1.0.9.ebuild,v 1.2 2007/05/06 23:17:05 pioto Exp $

EAPI="prefix"

inherit eutils

DESCRIPTION="Modular -config replacement utility"
HOMEPAGE="http://www.gentoo.org/proj/en/eselect/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-aix ~ppc-macos ~sparc-solaris ~x86 ~x86-macos ~x86-solaris"
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

	epatch "${FILESDIR}/${PN}-no-pgrep.patch"

	epatch "${FILESDIR}"/${PN}-1.0.9-prefix.patch
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

	elog "Modules cblas.eselect, blas.eselect and lapack.eselect have"
	elog "been split-out to separate packages called:"
	elog
	elog "  app-admin/eselect-cblas"
	elog "  app-admin/eselect-blas"
	elog "  app-admin/eselect-lapack"
}
