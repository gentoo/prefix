# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/elisp-common.eclass,v 1.21 2007/05/26 08:34:08 ulm Exp $
#
# Copyright 2007 Christian Faulhammer <opfer@gentoo.org>
# Copyright 2002-2007 Matthew Kennedy <mkennedy@gentoo.org>
# Copyright 2003 Jeremy Maitin-Shepard <jbms@attbi.com>
# Copyright 2007 Ulrich Mueller <ulm@gentoo.org>
#
# This is not a real eclass, but it does provide Emacs-related installation
# utilities.
#
# USAGE:
#
# Usually you want to use this eclass for (optional) GNU Emacs support of
# your package.  This is NOT for XEmacs!
#  Many of the steps here are sometimes done by the build system of your
# package (especially compilation), so this is mainly for standalone elisp
# files you gathered from somewhere else.
#  When relying on the emacs USE flag, you need to add
#
#		emacs? ( virtual/emacs )
#
# to your DEPEND/RDEPEND line and use the functions provided here to bring
# the files to the correct locations.
#
# src_compile() usage:
# --------------------
#
# An elisp file is compiled by the elisp-compile() function defined here and
# simply takes the source files as arguments.  In the case of interdependent
# elisp files, you can use the elisp-comp() function which makes sure all
# files are loadable.
#
#		elisp-compile *.el || die "elisp-compile failed!"
# or
#		elisp-comp *.el || die "elisp-comp failed!"
#
#  Function elisp-make-autoload-file() can be used to generate a file with
# autoload definitions for the lisp functions.  It takes the output file name
# (default: "${PN}-autoloads.el") and a list of directories (default: working
# directory) as its arguments.  Use of this function requires that the elisp
# source files contain magic ";;;###autoload" comments. See the Emacs Lisp
# Reference Manual (node "Autoload") for a detailed explanation.
#
# src_install() usage:
# --------------------
#
# The resulting compiled files (.elc) should be put in a subdirectory of
# /usr/share/emacs/site-lisp/ which is named after the first argument
# of elisp-install().  The following parameters are the files to be put in
# that directory.  Usually the subdirectory should be ${PN}, you can choose
# something else, but remember to tell elisp-site-file-install() (see below)
# the change, as it defaults to ${PN}.
#
#		elisp-install ${PN} *.elc *.el || die "elisp-install failed!"
#
#  To let the Emacs support be activated by Emacs on startup, you need
# to provide a site file (shipped in ${FILESDIR}) which contains the startup
# code (have a look in the documentation of your software).  Normally this
# would look like this:
#
#	;;; csv-mode site-lisp configuration
#
#	(add-to-list 'load-path "@SITELISP@")
#	(add-to-list 'auto-mode-alist '("\\.csv\\'" . csv-mode))
#	(autoload 'csv-mode "csv-mode" "Major mode for editing csv files." t)
#
#  If your Emacs support files are installed in a subdirectory of
# /usr/share/emacs/site-lisp/ (which is recommended if more than one file is
# installed), you need to extend Emacs' load-path as shown in the first
# non-comment.  The elisp-site-file-install() function of this eclass will
# replace "@SITELISP@" by the actual path.
#  The next line tells Emacs to load the mode opening a file ending with
# ".csv" and load functions depending on the context and needed features.
# Be careful though.  Commands as "load-library" or "require" bloat the
# editor as they are loaded on every startup.  When having a lot of Emacs
# support files, users may be annoyed by the start-up time.  Also avoid
# keybindings as they might interfere with the user's settings.  Give a hint
# in pkg_postinst(), which should be enough.
#  The naming scheme for this site file is "[0-9][0-9]*-gentoo.el", where the
# two digits at the beginning define the loading order.  So if you depend on
# another Emacs package, your site file's number must be higher!
#  Best practice is to define a SITEFILE variable in the global scope of your
# ebuild (right after DEPEND e.g.):
#
#		SITEFILE=50${PN}-gentoo.el
#
#  Which is then installed by
#
#		elisp-site-file-install "${FILESDIR}/${SITEFILE}"
#
# in src_install().  If your subdirectory is not named ${PN}, give the
# differing name as second argument.
#
# pkg_postinst() / pkg_postrm() usage:
# ------------------------------------
#
# After that you need to recreate the start-up file of Emacs after emerging
# and unmerging by using
#
#		pkg_postinst() {
#			elisp-site-regen
#		}
#		pkg_postrm() {
#			elisp-site-regen
#		}
#
#  As always: Feel free to contact Emacs team through emacs@gentoo.org if you
# have problems, suggestions or questions.

SITELISP="${EPREFIX}"/usr/share/emacs/site-lisp

elisp-compile() {
	${EPREFIX}/usr/bin/emacs --batch -f batch-byte-compile --no-site-file --no-init-file $*
}

elisp-make-autoload-file () {
	local f="${1:-${PN}-autoloads.el}"
	shift
	sed 's/^FF/\f/' >"${f}" <<-EOF
	;;; ${f##*/} --- autoloads for ${P}

	;;; Commentary:
	;; Automatically generated by elisp-common.eclass
	;; DO NOT EDIT THIS FILE

	;;; Code:
	FF
	;; Local Variables:
	;; version-control: never
	;; no-byte-compile: t
	;; no-update-autoloads: t
	;; End:
	;;; ${f##*/} ends here
	EOF
	emacs --batch -q --no-site-file \
		--eval "(setq make-backup-files nil)" \
		--eval "(setq generated-autoload-file (expand-file-name \"${f}\"))" \
		-f batch-update-autoloads "${@-.}"
}

elisp-install() {
	local subdir=$1
	dodir ${SITELISP#${EPREFIX}}/${subdir}
	insinto ${SITELISP#${EPREFIX}}/${subdir}
	shift
	doins $@
}

elisp-site-file-install() {
	local sitefile=$1 my_pn=${2:-${PN}}
	pushd ${S}
	cp ${sitefile} ${T}
	sed -i "s:@SITELISP@:${SITELISP}/${my_pn}:g" ${T}/$(basename ${sitefile})
	insinto ${SITELISP#${EPREFIX}}
	doins ${T}/$(basename ${sitefile}) || die "failed to install site file"
	popd
}

elisp-site-regen() {
	einfo "Regenerating ${SITELISP}/site-gentoo.el ..."
	einfo ""
	cat <<EOF >${SITELISP}/site-gentoo.el
;;; DO NOT EDIT THIS FILE -- IT IS GENERATED AUTOMATICALLY BY PORTAGE
;;; -----------------------------------------------------------------

EOF
	for sf in "${ROOT}${SITELISP}"/[0-9][0-9]*-gentoo.el
	do
		[ -r "${sf}" ] || continue
		einfo "  Adding $(basename ${sf}) ..."
		cat "${sf}" >> "${ROOT}${SITELISP}"/site-gentoo.el
	done
	while read line; do einfo "${line}"; done <<EOF

All site initialization for Gentoo-installed packages is now added to
/usr/share/emacs/site-lisp/site-gentoo.el; site-start.el is no longer
managed by Gentoo. You are responsible for all maintenance of
site-start.el if there is such a file.

In order for this site initialization to be loaded for all users
automatically, as was done previously, you can add a line like this:

	(load "/usr/share/emacs/site-lisp/site-gentoo" nil t)

to /usr/share/emacs/site-lisp/site-start.el.  Alternatively, that line
can be added by individual users to their initialization files, or for
greater flexibility, users can select which of the package-specific
initialization files in /usr/share/emacs/site-lisp to load.
EOF
	echo
}

# The following Emacs Lisp compilation routine is taken from GNU
# autotools.

elisp-comp() {
# Copyright 1995 Free Software Foundation, Inc.
# François Pinard <pinard@iro.umontreal.ca>, 1995.
# This script byte-compiles all `.el' files which are part of its
# arguments, using GNU Emacs, and put the resulting `.elc' files into
# the current directory, so disregarding the original directories used
# in `.el' arguments.
#
# This script manages in such a way that all Emacs LISP files to
# be compiled are made visible between themselves, in the event
# they require or load-library one another.

	if test $# = 0; then
		exit 1
	else
		if test -z "${EMACS}" || test "${EMACS}" = "t"; then
		# Value of "t" means we are running in a shell under Emacs.
		# Just assume Emacs is called "emacs".
			EMACS=emacs
		fi

		tempdir=elc.$$
		mkdir ${tempdir}
		cp $* ${tempdir}
		cd ${tempdir}

		echo "(add-to-list 'load-path \"../\")" > script
		${EMACS} -batch -q --no-site-file --no-init-file -l script -f batch-byte-compile *.el
		mv *.elc ..

		cd ..
		rm -fr ${tempdir}
	fi
}
