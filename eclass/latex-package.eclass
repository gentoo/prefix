# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/latex-package.eclass,v 1.29 2006/06/15 11:03:54 nattfodd Exp $
#
# Author Matthew Turk <satai@gentoo.org>
# Martin Ehmsen <ehmsen@gentoo.org>
# Maintained by the text-markup team <text-markup@gentoo.org>
#
# This eClass is designed to be easy to use and implement.  The vast majority of
# LaTeX packages will only need to define SRC_URI (and sometimes S) for a
# successful installation.  If fonts need to be installed, then the variable
# SUPPLIER must also be defined.
#
# However, those packages that contain subdirectories must process each
# subdirectory individually.  For example, a package that contains directories
# DIR1 and DIR2 must call latex-package_src_compile() and
# latex-package_src_install() in each directory, as shown here:
#
# src_compile() {
#    cd ${S}
#    cd DIR1
#    latex-package_src_compile
#    cd ..
#    cd DIR2
#    latex-package_src_compile
# }
#
# src_install() {
#    cd ${S}
#    cd DIR1
#    latex-package_src_install
#    cd ..
#    cd DIR2
#    latex-package_src_install
# }
#
# The eClass automatically takes care of rehashing TeX's cache (ls-lR) after
# installation and after removal, as well as creating final documentation from
# TeX files that come with the source.  Note that we break TeX layout standards
# by placing documentation in /usr/share/doc/${PN}
#
# For examples of basic installations, check out dev-tex/aastex and
# dev-tex/leaflet .
#
# NOTE: The CTAN "directory grab" function creates files with different MD5
# signatures EVERY TIME.  For this reason, if you are grabbing from the CTAN,
# you must either grab each file individually, or find a place to mirror an
# archive of them.  (iBiblio)

inherit base

DEPEND="virtual/tetex
	>=sys-apps/texinfo-4.2-r5"
HOMEPAGE="http://www.tug.org/"
SRC_URI="ftp://tug.ctan.org/macros/latex/"
S=${WORKDIR}/${P}
TEXMF="/usr/share/texmf"
SUPPLIER="misc" # This refers to the font supplier; it should be overridden

latex-package_has_tetex_3() {
	if has_version '>=app-text/tetex-3' || has_version '>=app-text/ptex-3.1.8' ; then
		true
	else
		false
	fi
}

latex-package_src_doinstall() {
	debug-print function $FUNCNAME $*
	# This actually follows the directions for a "single-user" system
	# at http://www.ctan.org/installationadvice/ modified for gentoo.
	[ -z "$1" ] && latex-package_src_install all

	while [ "$1" ]; do
		case $1 in
			"sh")
				for i in `find . -maxdepth 1 -type f -name "*.${1}"`
				do
					dobin $i || die "dobin $i failed"
				done
				;;
			"sty" | "cls" | "fd" | "clo" | "def" | "cfg")
				for i in `find . -maxdepth 1 -type f -name "*.${1}"`
				do
					insinto ${TEXMF}/tex/latex/${PN}
					doins $i || die "doins $i failed"
				done
				;;
			"dvi" | "ps" | "pdf")
				for i in `find . -maxdepth 1 -type f -name "*.${1}"`
				do
					insinto /usr/share/doc/${P}
					doins $i || "doins $i failed"
					#dodoc -u $i
				done
				;;
			"tex" | "dtx")
				for i in `find . -maxdepth 1 -type f -name "*.${1}"`
				do
					einfo "Making documentation: $i"
					texi2dvi -q -c --language=latex $i &> /dev/null
					done
				;;
			"tfm" | "vf" | "afm")
				for i in `find . -maxdepth 1 -type f -name "*.${1}"`
				do
					insinto ${TEXMF}/fonts/${1}/${SUPPLIER}/${PN}
					doins $i || die "doins $i failed"
				done
				;;
			"pfb")
				for i in `find . -maxdepth 1 -type f -name "*.pfb"`
				do
					insinto ${TEXMF}/fonts/type1/${SUPPLIER}/${PN}
					doins $i || die "doins $i failed"
				done
				;;
			"ttf")
				for i in `find . -maxdepth 1 -type f -name "*.ttf"`
				do
					insinto ${TEXMF}/fonts/truetype/${SUPPLIER}/${PN}
					doins $i || die "doins $i failed"
				done
				;;
			"bst")
				for i in `find . -maxdepth 1 -type f -name "*.bst"`
				do
					insinto ${TEXMF}/bibtex/bst/${PN}
					doins $i || die "doins $i failed"
				done
				;;
			"styles")
				latex-package_src_doinstall sty cls fd clo def cfg bst
				;;
			"doc")
				latex-package_src_doinstall tex dtx dvi ps pdf
				;;
			"fonts")
				latex-package_src_doinstall tfm vf afm pfb ttf
				;;
			"bin")
				latex-package_src_doinstall sh
				;;
			"all")
				latex-package_src_doinstall styles fonts bin doc
				;;
		esac
	shift
	done
}

latex-package_src_compile() {
	debug-print function $FUNCNAME $*
	for i in `find \`pwd\` -maxdepth 1 -type f -name "*.ins"`
	do
		einfo "Extracting from $i"
		latex --interaction=batchmode $i &> /dev/null
	done
}

latex-package_src_install() {
	debug-print function $FUNCNAME $*
	latex-package_src_doinstall all
	if [ -n "${DOCS}" ] ; then
		dodoc ${DOCS}
	fi
}

latex-package_pkg_postinst() {
	debug-print function $FUNCNAME $*
	latex-package_rehash
}

latex-package_pkg_postrm() {
	debug-print function $FUNCNAME $*
	latex-package_rehash
}

latex-package_rehash() {
	debug-print function $FUNCNAME $*
	if latex-package_has_tetex_3 ; then
		texmf-update
	else
		texconfig rehash
	fi
}

EXPORT_FUNCTIONS src_compile src_install pkg_postinst pkg_postrm
