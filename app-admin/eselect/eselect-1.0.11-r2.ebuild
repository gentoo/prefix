# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-admin/eselect/eselect-1.0.11-r2.ebuild,v 1.6 2009/05/24 19:30:15 ulm Exp $

inherit eutils prefix

DESCRIPTION="Modular -config replacement utility"
HOMEPAGE="http://www.gentoo.org/proj/en/eselect/"
SRC_URI="http://dev.gentooexperimental.org/~peper/distfiles/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~ppc-aix ~x86-freebsd ~ia64-hpux ~x86-interix ~amd64-linux ~ia64-linux ~x86-linux ~ppc-macos ~x86-macos ~m68k-mint ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc bash-completion vim-syntax"

RDEPEND="sys-apps/sed
	|| (
		sys-apps/coreutils
		sys-freebsd/freebsd-bin
		app-admin/realpath
	)"
DEPEND="${RDEPEND}
	doc? ( dev-python/docutils )"
RDEPEND="${RDEPEND}
	sys-apps/file"

src_unpack() {
	unpack ${A}

	cd "${S}"
	epatch "${FILESDIR}/${P}-fix-paludis-command.patch"
	epatch "${FILESDIR}/${P}-parent-profiles.patch"
	epatch "${FILESDIR}/${P}-relative-profiles.patch"

	# where does pgrep work?  Linux, Solaris and FreeBSD
	case ${CHOST} in
		*-linux-gnu|*-solaris*|*-freebsd*)
			: # leave it as is
		;;
		*)
			# revert to some layman's ps approach (not perfect at all)
			epatch "${FILESDIR}/${PN}-no-pgrep.patch"
		;;
	esac

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
		elog "In case you have not yet enabled command-line completion"
		elog "for eselect, you can run:"
		elog
		elog "  eselect bashcomp enable eselect"
		elog
		elog "to install locally, or"
		elog
		elog "  eselect bashcomp enable --global eselect"
		elog
		elog "to install system-wide."
	fi
}
