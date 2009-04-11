# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/gforth/gforth-0.6.2-r1.ebuild,v 1.6 2008/09/06 06:50:36 ulm Exp $

inherit elisp-common eutils toolchain-funcs flag-o-matic

DESCRIPTION="GNU Forth is a fast and portable implementation of the ANSI Forth language"
HOMEPAGE="http://www.gnu.org/software/gforth"
SRC_URI="http://www.complang.tuwien.ac.at/forth/gforth/${P}.tar.gz
	http://www.complang.tuwien.ac.at/forth/gforth/Patches/${PV}-debug.diff"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~x86-freebsd ~x86-linux ~ppc-macos"
IUSE="emacs force-reg"

DEPEND="virtual/libc
	dev-libs/ffcall
	emacs? ( virtual/emacs )"

SITEFILE=50gforth-gentoo.el

pkg_setup() {
	if use force-reg; then
		while read line; do ewarn "${line}"; done <<'EOF'

You have chosen to enable "force-reg" in USE.  From the GForth manual
(http://www.public.iastate.edu/~forth/gforth_141.html):

	"This feature not only depends on the machine, but also on the
	compiler version: On some machines some compiler versions produce
	incorrect code when certain explicit register declarations are
	used. So by default -DFORCE_REG is not used."

EOF
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	epatch "${FILESDIR}"/${PV}-ppc-configure-gentoo.patch	# Bug #131931
	epatch "${FILESDIR}"/gforth.el-gentoo.patch
	epatch "${FILESDIR}"/${PV}-c-to-forth-to-c.patch
	epatch "${DISTDIR}"/${PV}-debug.diff

}

src_compile() {
	filter-flags -Os -O0 -O1 -DFORCE_REG # Bug #120159
	append-flags -O2					 # Bug #120159

	econf CC="$(tc-getCC) -fno-reorder-blocks -fno-inline" \
		`use_enable force-reg force-reg` \
		|| die "econf failed"
	make || die
	if use emacs; then
		elisp-compile *.el || die
	fi
}

src_install() {
	make \
		libdir="${ED}"/usr/lib \
		infodir="${ED}"/usr/share/info \
		mandir="${ED}"/usr/share/man \
		datadir="${ED}"/usr/share \
		bindir="${ED}"/usr/bin \
		install || die

	dodoc AUTHORS BUGS ChangeLog NEWS* README* ToDo doc/glossaries.doc doc/*.ps

	if use emacs; then
		elisp-install ${PN} *.el *.elc || die
		elisp-site-file-install "${FILESDIR}"/${SITEFILE} || die
	fi
}

pkg_postinst() {
	use emacs && elisp-site-regen
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
