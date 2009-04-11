# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-emacs/slime/slime-2.0_p20080731.ebuild,v 1.6 2009/02/19 19:25:45 nixnut Exp $

inherit common-lisp elisp eutils prefix

DESCRIPTION="SLIME, the Superior Lisp Interaction Mode (Extended)"
HOMEPAGE="http://common-lisp.net/project/slime/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2 xref.lisp"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"
IUSE="doc"

RDEPEND="virtual/commonlisp dev-lisp/cl-asdf"
DEPEND="${RDEPEND}
	doc? ( virtual/texi2dvi )"

CLPACKAGE=swank
SITEFILE=70${PN}-gentoo.el

src_unpack() {
	unpack ${A}
	cd "${S}"

	cp "${FILESDIR}"/${PV}/${SITEFILE} "${S}"
	epatch "${FILESDIR}"/${PN}-prefix.patch
	eprefixify "${S}"/${SITEFILE}

	epatch "${FILESDIR}"/${PV}/module-load-gentoo.patch
	epatch "${FILESDIR}"/${PV}/dont-call-init.patch
	epatch "${FILESDIR}"/${PV}/inspect-presentations.patch
	epatch "${FILESDIR}"/${PV}/fix-ecl.patch
	epatch "${FILESDIR}"/${PV}/fix-swank-listener-hooks-contrib.patch
	epatch "${FILESDIR}"/${PV}/fix-slime-indentation.patch
	epatch "${FILESDIR}"/${PV}/changelog-date.patch

	# extract date of last update from ChangeLog, bug 233270
	SLIME_CHANGELOG_DATE=$(awk '/^[-0-9]+ / { print $1; exit; }' ChangeLog)
	[ -n "${SLIME_CHANGELOG_DATE}" ] || die "cannot determine ChangeLog date"

	sed -i "/(defvar \*swank-wire-protocol-version\*/s:nil:\"${SLIME_CHANGELOG_DATE}\":" swank.lisp \
		|| die "sed swank.lisp failed"
	sed -i "s:@SLIME-CHANGELOG-DATE@:${SLIME_CHANGELOG_DATE}:" slime.el \
		|| die "sed slime.el failed"
}

src_compile() {
	elisp-compile *.el || die "Cannot compile core Elisp files"
	BYTECOMPFLAGS="${BYTECOMPFLAGS} -L contrib -l slime" \
		elisp-compile contrib/*.el || die "Cannot compile contrib Elisp files"
	emake -j1 -C doc slime.info || die "Cannot build info docs"
	if use doc; then
		VARTEXFONTS="${T}"/fonts \
			emake -j1 -C doc slime.{ps,pdf} || die "emake doc failed"
	fi
}

src_install() {
	## install core
	elisp-install ${PN} *.el{,c} "${FILESDIR}"/swank-loader.lisp \
		|| die "Cannot install SLIME core"
	elisp-site-file-install "${S}"/${SITEFILE} \
		|| die "elisp-site-file-install failed"
	cp "${FILESDIR}"/${PV}/swank.asd "${S}"
	# remove upstream swank-loader, since it won't be used
	rm "${S}"/swank-loader.lisp
	insinto "${CLSOURCEROOT%/}"/swank
	doins *.lisp "${FILESDIR}"/${PV}/swank.asd
	dodir "${CLSYSTEMROOT}"
	dosym "${CLSOURCEROOT%/}"/swank/swank.asd "${CLSYSTEMROOT}"
	dosym "${SITELISP}"/${PN}/swank-version.el "${CLSOURCEROOT%/}"/swank

	## install contribs
	elisp-install ${PN}/contrib/ contrib/*.{el,elc,scm,goo} \
		|| die "Cannot install contribs"
	insinto "${CLSOURCEROOT%/}"/swank/contrib
	doins contrib/*.lisp

	## install docs
	dodoc README* ChangeLog HACKING NEWS PROBLEMS
	newdoc contrib/README README.contrib
	newdoc contrib/ChangeLog ChangeLog.contrib
	doinfo doc/slime.info
	use doc && dodoc doc/slime.{ps,pdf}
}
