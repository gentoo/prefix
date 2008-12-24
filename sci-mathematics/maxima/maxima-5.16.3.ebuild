# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-mathematics/maxima/maxima-5.16.3.ebuild,v 1.3 2008/11/29 04:02:07 grozin Exp $

EAPI="prefix"
inherit eutils elisp-common

DESCRIPTION="Free computer algebra environment based on Macsyma"
HOMEPAGE="http://maxima.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2 AECA"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~x86-macos"

# Supported lisps with readline
SUPP_RL="gcl clisp"
# Supported lisps without readline
SUPP_NORL="cmucl sbcl"
SUPP_LISPS="${SUPP_RL} ${SUPP_NORL}"
# Default lisp if none selected
DEF_LISP="sbcl"

IUSE="latex emacs tk nls unicode xemacs X ${SUPP_LISPS} ${IUSE}"

# Languages
LANGS="es pt pt_BR"
for lang in ${LANGS}; do
	IUSE="${IUSE} linguas_${lang}"
done

# >=maxima-5.15.0 includes imaxima; it depends on dev-tex/mh
RDEPEND="!app-emacs/imaxima
	X? ( x11-misc/xdg-utils
		 sci-visualization/gnuplot
		 tk? ( dev-lang/tk ) )
	latex? ( || ( dev-texlive/texlive-latexrecommended
				  >=app-text/tetex-3
				  app-text/ptex ) )
	emacs? ( virtual/emacs
		latex? ( app-emacs/auctex dev-tex/mh ) )
	xemacs? ( virtual/xemacs
		latex? ( app-emacs/auctex
				|| ( dev-tex/mh =dev-texlive/texlive-mathextra-2007* ) ) )"

# create lisp dependencies
for LISP in ${SUPP_LISPS}; do
	RDEPEND="${RDEPEND} ${LISP}? ( dev-lisp/${LISP} )"
	DEF_DEP="${DEF_DEP} !${LISP}? ( "
done
DEF_DEP="${DEF_DEP} dev-lisp/${DEF_LISP}"
for LISP in ${SUPP_NORL}; do
	RDEPEND="${RDEPEND} ${LISP}? ( app-misc/rlwrap )"
	[[ ${LISP} = ${DEF_LISP} ]] && \
		DEF_DEP="${DEF_DEP} app-misc/rlwrap"
done
for LISP in ${SUPP_LISPS}; do
	DEF_DEP="${DEF_DEP} )"
done

RDEPEND="${RDEPEND}
	${DEF_DEP}"

DEPEND="${RDEPEND}
	sys-apps/texinfo"

TEXMF=/usr/share/texmf-site

pkg_setup() {
	LISPS=""

	for LISP in ${SUPP_LISPS}; do
		use ${LISP} && LISPS="${LISPS} ${LISP}"
	done

	if [ -z "${LISPS}" ]; then
		ewarn "No lisp specified in USE flags, choosing ${DEF_LISP} as default"
		LISPS="${DEF_LISP}"
	fi

	RL=""

	for LISP in ${SUPP_NORL}; do
		use ${LISP} && RL="yes"
	done

	if use gcl; then
		if ! built_with_use dev-lisp/gcl ansi; then
			eerror "gcl must be emerged with the USE flag ansi"
			die "This package needs gcl with USE=ansi"
		fi
		# gcl in the main tree is broken (bug #205803)
		ewarn "Please use gcl from http://repo.or.cz/w/gentoo-lisp-overlay.git"
	fi

	if use X && ! built_with_use sci-visualization/gnuplot gd wxwindows; then
		elog "To benefit full plotting capability of maxima,"
		elog "enable the gd USE flag for sci-visualization/gnuplot"
		elog "And if you are planning to use wxmaxima, you want to"
		elog "also add the wxwindows flag to gnuplot."
		epause 5
	fi
}

src_unpack() {
	unpack ${A}
	cd "${S}"
	# use xdg-open to view ps, pdf
	epatch "${FILESDIR}"/${PN}-xdg-utils.patch
	epatch "${FILESDIR}"/${PN}-no-init-files.patch
	# remove rmaxima if neither cmucl nor sbcl
	if [ -z "${RL}" ]; then
		sed -e '/^@WIN32_FALSE@bin_SCRIPTS/s/rmaxima//' \
			-i "${S}"/src/Makefile.in \
			|| die "sed for rmaxima failed"
	fi
}

src_compile() {
	local myconf=""
	for LISP in ${LISPS}; do
		myconf="${myconf} --enable-${LISP}"
	done

	# remove xmaxima if no tk
	if use tk; then
		myconf="${myconf} --with-wish=wish"
	else
		myconf="${myconf} --with-wish=none"
		sed -i \
			-e '/^SUBDIRS/s/xmaxima//' \
			interfaces/Makefile.in || die "sed for tk failed"
	fi

	# enable existing translated doc
	if use nls; then
		for lang in ${LANGS}; do
			if use "linguas_${lang}"; then
				myconf="${myconf} --enable-lang-${lang}"
				use unicode && myconf="${myconf} --enable-lang-${lang}-utf8"
			fi
		done
	fi

	econf ${myconf}
	emake || die "emake failed"
}

src_install() {
	einstall emacsdir="${D}${ESITELISP}/${PN}" || die "einstall failed"

	use tk && make_desktop_entry xmaxima xmaxima \
		/usr/share/${PN}/${PV}/xmaxima/maxima-new.png \
		"Science;Math;Education"

	if use latex; then
		insinto ${TEXMF}/tex/latex/emaxima
		doins interfaces/emacs/emaxima/emaxima.sty
	fi

	# do not use dodoc because interfaces can't read compressed files
	# read COPYING before attempt to remove it from dodoc
	insinto /usr/share/${PN}/${PV}/doc
	doins AUTHORS COPYING README README.lisps || die
	dodir /usr/share/doc
	dosym ../${PN}/${PV}/doc /usr/share/doc/${PF} || die

	if use emacs; then
		elisp-site-file-install "${FILESDIR}"/50maxima-gentoo.el
		# imaxima docs
		cd interfaces/emacs/imaxima
		insinto /usr/share/${PN}/${PV}/doc/imaxima
		doins ChangeLog NEWS README || die "installing imaxima docs failed"
		insinto /usr/share/${PN}/${PV}/doc/imaxima/imath-example
		doins imath-example/*.txt || die "installing imaxima docs failed"
	fi
}

pkg_preinst() {
	# some lisps do not read compress info files (bug #176411)
	for infofile in "${ED}"/usr/share/info/*.bz2 ; do
		bunzip2 "${infofile}"
	done
	for infofile in "${ED}"/usr/share/info/*.gz ; do
		gunzip "${infofile}"
	done
}

pkg_postinst() {
	use emacs && elisp-site-regen
	use latex && mktexlsr
}

pkg_postrm() {
	use emacs && elisp-site-regen
}
