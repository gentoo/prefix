# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect/eselect-1.0.5.ebuild,v 1.1 2006/08/26 17:04:26 kugelfang Exp $

EAPI="prefix"

DESCRIPTION="Modular -config replacement utility"
HOMEPAGE="http://www.gentoo.org/proj/en/eselect/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc-macos ~x86"
IUSE="doc bash-completion"

DEPEND="sys-apps/sed
	doc? ( dev-python/docutils )
	|| (
		sys-apps/coreutils
		sys-freebsd/freebsd-bin
		app-admin/realpath
	)"
RDEPEND="sys-apps/sed
	sys-apps/file"

src_compile() {
	econf || die "econf failed"
	emake || die "emake failed"

	if use doc ; then
		make html || die "failed to build html"
	fi
}

src_install() {
	make DESTDIR="${EDEST}" install || die "make install failed"
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
		echo
		einfo
		einfo "To enable command-line completion for eselect, run:"
		einfo
		einfo "  eselect bashcomp enable eselect"
		einfo
		echo
	fi

	echo
	einfo "Modules cblas.eselect, blas.eselect and lapack.eselect have"
	einfo "been split-out to separate packages called:"
	einfo
	einfo "  app-admin/eselect-cblas"
	einfo "  app-admin/eselect-blas"
	einfo "  app-admin/eselect-lapack"
	einfo
	echo
}
