# Copyright 1999-2004 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/eclass/findlib.eclass,v 1.7 2008/02/02 21:10:16 betelgeuse Exp $
#
# Original author : Matthieu Sozeau <mattam@gentoo.org> (retired)
#
# Changes: http://sources.gentoo.org/viewcvs.py/gentoo-x86/eclass/findlib.eclass?view=log
# 
# ocamlfind (a.k.a. findlib) eclass
#


# From this findlib version there is proper stublibs support.
DEPEND=">=dev-ml/findlib-1.0.4-r1"
[[ ${FINDLIB_USE} ]] && DEPEND="${FINDLIB_USE}? ( ${DEPEND} )"

check_ocamlfind() {
	if [ ! -x "${EPREFIX}"/usr/bin/ocamlfind ]
	then
		eerror "In findlib.eclass: could not find the ocamlfind executable"
		eerror "Please report this bug on gentoo's bugzilla, assigning to ml@gentoo.org"
		die "ocamlfind executabled not found"
	fi
}

# Prepare the image for a findlib installation.
# We use the stublibs style, so no ld.conf needs to be
# updated when a package installs C shared libraries.
findlib_src_preinst() {
	check_ocamlfind

	# destdir is the ocaml sitelib
	local destdir=`ocamlfind printconf destdir`

	# strip off prefix
	destdir=${destdir#${EPREFIX}}

	dodir ${destdir} || die "dodir failed"
	export OCAMLFIND_DESTDIR=${ED}${destdir}

	# stublibs style
	dodir ${destdir}/stublibs || die "dodir failed"
	export OCAMLFIND_LDCONF=ignore
}

# Install with a properly setup findlib
findlib_src_install() {
	findlib_src_preinst
	make DESTDIR=${D} "$@" install || die "make failed"
}
