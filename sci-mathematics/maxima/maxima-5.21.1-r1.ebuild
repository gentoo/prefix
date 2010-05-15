# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sci-mathematics/maxima/maxima-5.21.1-r1.ebuild,v 1.1 2010/05/01 12:18:10 grozin Exp $
EAPI=2
inherit eutils elisp-common

DESCRIPTION="Free computer algebra environment based on Macsyma"
HOMEPAGE="http://maxima.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"

# Supported lisps with readline
SUPP_RL="gcl clisp"
# Supported lisps without readline
SUPP_NORL="cmucl sbcl ecl openmcl"
SUPP_LISPS="${SUPP_RL} ${SUPP_NORL}"
# Default lisp if none selected
DEF_LISP="sbcl"

IUSE="latex emacs tk nls unicode xemacs X ${SUPP_LISPS} ${IUSE}"

# Languages
LANGS="es pt pt_BR"
for lang in ${LANGS}; do
	IUSE="${IUSE} linguas_${lang}"
done

RDEPEND="X? ( x11-misc/xdg-utils
		 sci-visualization/gnuplot[gd]
		 tk? ( dev-lang/tk ) )
	latex? ( virtual/latex-base )
	emacs? ( virtual/emacs
		latex? ( app-emacs/auctex ) )
	xemacs? ( app-editors/xemacs
		latex? ( app-emacs/auctex ) )"

PDEPEND="emacs? ( app-emacs/imaxima )"

# create lisp dependencies
for LISP in ${SUPP_LISPS}; do
	if [ "${LISP}" = "gcl" ]
	then
		RDEPEND="${RDEPEND} gcl? ( >=dev-lisp/gcl-2.6.8_pre[ansi] )"
	else if [ "${LISP}" = "ecl" ]
	then
		RDEPEND="${RDEPEND} ecl? ( >=dev-lisp/ecls-10.4.1 )"
	else if [ "${LISP}" = "openmcl" ]
	then
		RDEPEND="${RDEPEND} openmcl? ( dev-lisp/clozurecl )"
	else
		RDEPEND="${RDEPEND} ${LISP}? ( dev-lisp/${LISP} )"
	fi
	fi
	fi
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
NO_INIT_PATCH_PV="5.19.1"

pkg_setup() {
	LISPS=""

	for LISP in ${SUPP_LISPS}; do
		use ${LISP} && LISPS="${LISPS} ${LISP}"
	done

	RL=""

	for LISP in ${SUPP_NORL}; do
		use ${LISP} && RL="yes"
	done

	if [ -z "${LISPS}" ]; then
		ewarn "No lisp specified in USE flags, choosing ${DEF_LISP} as default"
		LISPS="${DEF_LISP}"
		RL="yes"
	fi
}

src_prepare() {
	# use xdg-open to view ps, pdf
	epatch "${FILESDIR}"/${PN}-xdg-utils.patch

	# Don't use lisp init files
	# ClozureCL executable name is now ccl
	# *read-default-float-format* is now bound per-thread
	# and isn't saved in a heap image
	epatch "${FILESDIR}"/${P}.patch

	epatch "${FILESDIR}"/${P}-emacs-version.patch

	# remove rmaxima if not needed
	if [ -z "${RL}" ]; then
		sed -e '/^@WIN32_FALSE@bin_SCRIPTS/s/rmaxima//' \
			-i "${S}"/src/Makefile.in \
			|| die "sed for rmaxima failed"
	fi

	# don't install imaxima, since we have a separate package for it
	sed -i -e '/^SUBDIRS/s/imaxima//' interfaces/emacs/Makefile.in \
		|| die "sed for imaxima failed"
}

src_configure() {
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
}

src_install() {
	einstall emacsdir="${ED}${SITELISP}/${PN}" || die "einstall failed"

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
		elisp-site-file-install "${FILESDIR}"/50maxima-gentoo.el || die
	fi
}

pkg_preinst() {
	# some lisps do not read compress info files (bug #176411)
	for infofile in "${ED}"/usr/share/info/*.bz2 ; do
		bunzip2 "${infofile}"
	done
}

pkg_postinst() {
	use emacs && elisp-site-regen
	use latex && mktexlsr
}

pkg_postrm() {
	use emacs && elisp-site-regen
	use latex && mktexlsr
}
